/*
Author: TalkLounge
Mail: talklounge@yahoo.de

***Build***
mkdir build
"C:\Program Files\Java\jdk1.8.0_151\bin\javac.exe" -d ./build Serverlist.java
cd ./build
"C:\Program Files\Java\jdk1.8.0_151\bin\jar.exe" cfe Serverlist.jar Serverlist *
move Serverlist.jar ..

***Execute***
java -jar Serverlist.jar
*/

import java.io.IOException;
import java.net.URL;
import java.util.Scanner;

public class Serverlist {
	public static void main(String[] args) {
		try {
			URL URL = new URL("http://servers.minetest.net/list?proto_version_min=0&proto_version_max=100");
			Scanner sc = new Scanner(URL.openStream());
			System.out.println(sc.nextLine());
			sc.close();
		} catch(IOException ex) {
			ex.printStackTrace();
		}
		System.exit(0);
	}
}
