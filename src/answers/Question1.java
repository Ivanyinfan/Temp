package answers;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.filecache.DistributedCache;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.WritableComparator;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

@SuppressWarnings("deprecation")
public class Question1
{
	public static class Q1Map extends Mapper<LongWritable,Text,Text,Text>
	{
		private Map<String,String> devMap=new HashMap<String,String>();
		private String[] kv;
		
		protected void setup(Context context) throws IOException
		{
			BufferedReader br = null;
			String path = DistributedCache.getLocalCacheFiles(context.getConfiguration())[0].getName();
			String devInfo = null;
			br = new BufferedReader(new FileReader(path));
			while((devInfo=br.readLine())!=null)
			{
				String[] dev = devInfo.split(",");
				devMap.put(dev[0],dev[1]);
			}
			br.close();
		}
		
		public void map(LongWritable key,Text value,Context context) throws IOException, InterruptedException
		{
			if(context.getInputSplit().toString().contains("device.txt"))
				return;
			kv=value.toString().split(",");
			if(devMap.containsKey(kv[0]))
			{
				if(Integer.parseInt(kv[0])>0&&Integer.parseInt(kv[0])<1000&&kv[1].toString().equals("\\N"))
				{
					context.write(new Text(devMap.get(kv[0]).trim()), new Text((kv[2].trim())));
				}
			}
		}
	}

	public static class Q1Reduce extends Reducer<Text,Text,Text,Text>
	{
		public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException
		{
			BigDecimal sumValue=new BigDecimal(0);
			for(Text value:values)
			{
				sumValue=sumValue.add(new BigDecimal(value.toString()));
			}
			context.write(key, new Text(sumValue.toString()));
		}
	}

	@SuppressWarnings("rawtypes")
	public static class Q1Sort extends WritableComparator
	{
		public Q1Sort()
		{
            super(Text.class,true);  
        }
		
		@Override
		public int compare(WritableComparable a,WritableComparable b)
		{
			return ((Text)b).toString().compareTo(((Text)a).toString());	
		}
	}
	
	public static void main(String[] args) throws Exception
	{
		Configuration conf = new Configuration();
		String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
		if (otherArgs.length < 2)
		{
			System.err.println("Usage: Question1 <in> [<in>...] <out>");
			System.exit(2);
		}
		DistributedCache.addCacheFile(new Path(args[0]+"/device.txt").toUri(), conf);
		Job job = Job.getInstance(conf, "Question1");
		job.setJarByClass(Question1.class);
		job.setMapperClass(Q1Map.class);
		job.setCombinerClass(Q1Reduce.class);
		job.setReducerClass(Q1Reduce.class);
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);
		job.setSortComparatorClass(Q1Sort.class);
		for (int i = 0; i < otherArgs.length - 1; ++i) {
			FileInputFormat.addInputPath(job, new Path(otherArgs[i]));
		}
		FileOutputFormat.setOutputPath(job, new Path(otherArgs[otherArgs.length - 1]));
		System.exit(job.waitForCompletion(true) ? 0 : 1);
	}
}