//Sposób na uzyskanie nazwy hosta w Javie. Ale cos nie działa TODO
//https://stackoverflow.com/questions/7348711/recommended-way-to-get-hostname-in-java
/////////////////////////////////////////////////////////////////////////////////////////////
import java.net.InetAddress;
import java.net.UnknownHostException;

public class localHost {
    public static String hostName;
    public static String canonicalHostName;
    public localHost() {
        hostName="unkn";
        canonicalHostName="unkn";
    }
    
   public void run() throws UnknownHostException {
        InetAddress iAddress = InetAddress.getLocalHost();
        hostName = iAddress.getHostName();
        canonicalHostName = iAddress.getCanonicalHostName();        //To get  the Canonical host name
        //System.out.println("HostName:" + hostName);
        //System.out.println("Canonical Host Name:" + canonicalHostName);
    }
}