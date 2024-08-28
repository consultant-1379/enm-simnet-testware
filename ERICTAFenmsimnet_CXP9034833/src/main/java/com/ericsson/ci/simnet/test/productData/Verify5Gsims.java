package com.ericsson.ci.simnet.test.productData;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * Created by xkatmri on 02/08/2016.
 */
public class Verify5Gsims {

	public static void main(String[] args) throws IOException {

		if (args.length != 2) {
			System.out.println("Proper Usage is: java -jar Verify5Gsims.jar <Simulation Name> <No of Nodes>");

			System.exit(0);
		}

		String sim_name = args[0];
		int No_of_Nodes = Integer.parseInt(args[1]);
		String sim_num = sim_name.substring(sim_name.length() - 2);
		int sim_no = Integer.parseInt(sim_num);
		ArrayList<String> mml_names = new ArrayList<String>();
		SimpleDateFormat format = new SimpleDateFormat("yyyy_MM_dd_hh_mm_ss");
		String timeStamp = format.format(new Date());
		String Logs_File_Name = "validateProductData_" + timeStamp + "_logs.txt";
		String[] NE_Names = new String[No_of_Nodes];
		String[] productNumber = new String[No_of_Nodes];
		String[] productRevision = new String[No_of_Nodes];
		NE_Names = get_node_names(sim_name, sim_no, No_of_Nodes);

		del_runtime_files(NE_Names);

		Kertyle_gen_mml(sim_name, "ker_gen.mml", NE_Names, sim_no, No_of_Nodes);

		mml_names.add("ker_gen.mml");
		build_script(mml_names);
		mml_names.removeAll(mml_names);
		String output_1 = executeCommand("./script.sh");

		File newFile = new File(Logs_File_Name);
		FileWriter fw = new FileWriter(newFile, true);
		fw.write(output_1);
		fw.close();

		for (int output = 0; output < NE_Names.length; ++output) {

			String[] out = checkProductData(NE_Names[output] + ".mo");

			productNumber[output] = out[0];
			productRevision[output] = out[1];
		}

		String arg21 = "LTE_data_" + sim_num + ".csv";
		PrintWriter arg22 = new PrintWriter(new BufferedWriter(new FileWriter(arg21, false)));

		arg22.println("NodeName,productNumber,productRevision");
		System.out.println("INFO : started checking for existence of ProductData on the nodes");
		for (int i = 0; i < NE_Names.length; ++i) {

			arg22.println(NE_Names[i] + "," + productNumber[i] + "," + productRevision[i]);
			boolean productData = false;

			if (productNumber[i].contains("CXP") && !productRevision[i].equals("")) {
				productData = true;
			}
			if (productData) {
				System.out.println("INFO : The Node " + NE_Names[i] + " contains product data");
			} else {
				System.out.println("ERROR : The Node " + NE_Names[i] + " contains  invalid product data");
				System.out.println(
						"INFO : Please check the output file which contains product data on the nodes in csv format");
			}
		}

		arg22.close();

		del_runtime_files(NE_Names);

	}

	public static void Kertyle_gen_mml(String SIM_Name, String File_Name, String[] NE_Names, int sim_no,
			int no_of_nodes) {
		String[] Kertyle_Names = new String[NE_Names.length];

		try {
			PrintWriter e = new PrintWriter(new BufferedWriter(new FileWriter(File_Name, false)));
			e.println(".open " + SIM_Name);

			for (int i = 0; i < NE_Names.length; ++i) {

				Kertyle_Names[i] = "Kertyle" + (i + 1) + ".mo";
				e.println(".select " + NE_Names[i]);
				e.println(".start");

				String moId;

				moId = "ComTop:ManagedElement=" + NE_Names[i] + ",ComTop:SystemFunctions=1,RcsSwIM:SwInventory=1";

				e.println("dumpmotree:moid=\"" + moId + "\",ker_out,outputfile=\""
						+ get_absolute_path(NE_Names[i] + ".mo") + "\";");

			}

			e.close();

		} catch (IOException arg10) {

			arg10.printStackTrace();
		}
	}

	public static String[] get_node_names(String sim_name, int sim_no, int No_of_Nodes) {
		String[] NE_Names = new String[No_of_Nodes];
		String sim_no_mod;
		if (sim_no < 10) {
			sim_no_mod = "0" + Integer.toString(sim_no);
		} else {
			sim_no_mod = Integer.toString(sim_no);
		}
		String sim_prefix = null;
		if (sim_name.contains("RNNODE")) {
			sim_prefix = "RNNode";
		} else if (sim_name.contains("vPP")) {
			sim_prefix = "vPP";
		} else if (sim_name.contains("vRC")) {
			sim_prefix = "vRC";
		} else if (sim_name.contains("VTFRadioNode")) {
			sim_prefix = "VTFRadioNode";
		} else if (sim_name.contains("vSD")) {
			sim_prefix = "vSD";
		} else if (sim_name.contains("RAN-VNFM")) {
			sim_prefix = "RANVNFM";
		}

		for (int i = 0; i < No_of_Nodes; ++i) {
			if (i < 9) {
				NE_Names[i] = "LTE" + sim_no_mod + sim_prefix + "0000" + (i + 1);

			} else if (i < 99) {
				NE_Names[i] = "LTE" + sim_no_mod + sim_prefix + "000" + (i + 1);

			} else {
				NE_Names[i] = "LTE" + sim_no_mod + sim_prefix + "00" + (i + 1);
			}
		}

		return NE_Names;
	}

	public static String get_absolute_path(String name) {
		File directory = new File(name);
		boolean isDirectory = directory.isDirectory();
		String Path;
		if (isDirectory) {
			Path = directory.getAbsolutePath();
		} else {
			Path = directory.getAbsolutePath();
		}
		return Path;
	}

	public static void build_script(ArrayList<String> mml_names) {
		try {
			File e1 = new File("script.sh");
			FileWriter fw = new FileWriter("script.sh");
			e1.setExecutable(true);
			e1.setReadable(true);
			e1.setWritable(true);
			PrintWriter pw = new PrintWriter(fw);

			pw.println("#!/bin/bash");
			pw.println("add1=\"/netsim/inst/\";");
			pw.println("add2=$add1.\"/netsim_shell\";");
			pw.println("call_mmlfunction()");
			pw.println("{");
			for (int i = 0; i < mml_names.size(); ++i) {
				pw.println("echo \".send " + get_absolute_path(mml_names.get(i)) + "\"");
			}
			pw.println("}");
			pw.println("(");
			pw.println("call_mmlfunction");
			pw.println(") | $add2");
			pw.close();

		} catch (IOException arg4) {

			arg4.printStackTrace();
		}
	}

	public static String executeCommand(String command) {
		StringBuffer output = new StringBuffer();

		try {
			Process e = Runtime.getRuntime().exec(command);
			e.waitFor();
			BufferedReader reader = new BufferedReader(new InputStreamReader(e.getInputStream()));

			String line = "";
			while ((line = reader.readLine()) != null) {
				output.append(line + "\n");

			}
		} catch (Exception arg4) {

			arg4.printStackTrace();
		}
		return output.toString();
	}

	public static Integer getMOsCount(String File_to_be_read, String moType) throws IOException {
		new ArrayList<Object>();
		int count = 0;
		ArrayList<String> file_array = write_file_to_arrlist(File_to_be_read);
		for (int i = 0; i < file_array.size(); ++i) {

			String linetocheck = "moType ComTop:" + moType;

			if (((String) file_array.get(i)).contains(linetocheck)) {
				++count;
			}
		}

		return Integer.valueOf(count);
	}

	public static ArrayList<String> write_file_to_arrlist(String File_to_be_read) throws IOException {
		ArrayList<String> all_lines = new ArrayList<String>();

		FileReader file = new FileReader(File_to_be_read);

		BufferedReader BR1 = new BufferedReader(file);
		String line1;
		while ((line1 = BR1.readLine()) != null) {

			all_lines.add(line1);
		}
		BR1.close();

		return all_lines;
	}

	public static String[] checkProductData(String File_to_be_read) throws IOException {
		@SuppressWarnings("unused")
		boolean isProductValid = false;
		new ArrayList<Object>();
		ArrayList<String> file_array = write_file_to_arrlist(File_to_be_read);
		String ProductNumber = null;
		String productRevision = null;

		for (int productData = 0; productData < file_array.size(); ++productData) {

			byte offset = 0;
			String linetocheck = "moType RcsSwIM:SwVersion";
			offset = 1;

			if (file_array.get(productData).contains(linetocheck)) {

				int administrativeDataLine = 0;
				if (file_array.get(productData - 1).contains("identity \"1\"")) {

					for (int k = productData; k < file_array.size(); ++k) {
						if (file_array.get(k).contains("\"administrativeData\" Struct")) {
							administrativeDataLine = k;
							break;
						}
					}

					if (administrativeDataLine != 0) {

						ProductNumber = file_array.get(administrativeDataLine + offset + 2).replaceAll("\"", "")
								.replaceAll("productNumber String ", "").replaceAll(" ", "");

						productRevision = file_array.get(administrativeDataLine + offset + 3).replaceAll("\"", "")
								.replaceAll("productRevision String ", "").replaceAll(" ", "");

						if (ProductNumber.contains("CXP") && !productRevision.equals("")) {
							isProductValid = true;
							break;
						}
					}
				}
			}
		}

		String[] arg11 = new String[] { ProductNumber, productRevision };

		return arg11;
	}

	public static void del_runtime_files(String[] NE_Names) {
		check_mml("ker_gen.mml");
		for (int i = 0; i < NE_Names.length; ++i) {
			check_mml(NE_Names[i] + ".mo");
		}
	}

	public static void check_mml(String File_Name) {
		File f = new File(File_Name);

		if (f.exists()) {
			f.delete();
		}
	}

}
