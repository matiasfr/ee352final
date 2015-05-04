import java.io.*;
import java.math.BigInteger;
import java.util.Random;

/**
 * Created by idean on 5/3/15.
 */


public class FinalProject {
    private static final int SLOTS          = 1024;
    private static final int SLOTS_PER_SET  = 2;
    private static final int SETS           = SLOTS / SLOTS_PER_SET;

    private static final int TOTAL_BITS     = 16;
    private static final int OFFSET_BITS    = 5;                                              //32 bytes per slot
    private static final int SET_BITS       = (int) Math.round(Math.log(SETS) / Math.log(2)); //log(slots per set)
    private static final int TAG_BITS       = TOTAL_BITS-(OFFSET_BITS+SET_BITS);
    private static final int BYTES_PER_SLOT = (int) Math.pow(2,OFFSET_BITS);                  //unused

    private static final int NUM_ADDRESSES  = 100000;
    private static final int MISS_PENALTY   = 5;

    private static final boolean USE_LRU    = true;

    private static final String FILE_NAME   = "./addresses.txt";

    private static long[][] cache = new long[SETS][SLOTS_PER_SET];  //each cell of this 2-d array holds the tag of a slot.

    private static int hits   = 0;
    private static int misses = 0;
    private static int cycles = 0;


    public static void main(String[] args) {
        try {
            initializeAddressFile(FILE_NAME);
        } catch (IOException e) {
            e.printStackTrace();
        }

        printIntro();

        initializeCache();

        try(BufferedReader br = new BufferedReader(new FileReader(FILE_NAME))) {
            for(String line; (line = br.readLine()) != null; ) {
                if(line.length() != TOTAL_BITS) {
                    throw new RuntimeException("Line was not " + TOTAL_BITS + " bits!");
                }

                String binaryTag = line.substring(0, TAG_BITS);
                Long tag = (new BigInteger(binaryTag,2)).longValueExact();
                String binarySet = line.substring(TAG_BITS, TAG_BITS + SET_BITS);
                int set = Integer.parseInt(binarySet, 2);

                boolean found = isFound(tag, cache[set]);

                if(found) {
                    hits++;
                } else {
                    misses++;
                    cycles += MISS_PENALTY;
                    place(tag, cache[set]);
                }


            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        printStatistics();

    }

    private static void initializeCache() {
        for(int i = 0; i < cache.length; i++) {
            for(int j = 0; j < cache[0].length; j++) {
                cache[i][j] = -1;
            }
        }
    }

    private static void printStatistics() {
        double hitPercentage = (1.0 * hits)/NUM_ADDRESSES;

        System.out.println("Hits: " + hits);
        System.out.println("Misses: " + misses);
        System.out.println("Runtime: " + cycles + " cycles");
        System.out.println("Hit percentage: " + (hitPercentage * 100) + "%");
    }

    private static void place(Long tag, long[] longs) {
        boolean placed = false;
        for(int i = 0; i < SLOTS_PER_SET; i++) {
            if(longs[i] == 0) {
                longs[i] = tag;
                placed = true;
            }
        }
        if(!placed) {
            if(USE_LRU) {
                pushBackAndPlace(tag, longs);
            } else {
                Random r = new Random();
                longs[r.nextInt(SLOTS_PER_SET)] = tag;
            }
        }
    }

    private static void pushBackAndPlace(Long tag, long[] longs) {
        for(int i = longs.length - 2; i >= 0; i--) {
            longs[i+1] = longs[i];
        }
        longs[0] = tag;
    }

    private static boolean isFound(Long tag, long[] longs) {
        int slot = 0;

        while(slot < SLOTS_PER_SET) {
            if(longs[slot] == tag) {
                return true;
            }
            slot++;
        }
        return false;
    }

    private static void printIntro() {
        System.out.println("Starting Simulation...");
        System.out.println("Number of slots: " + SLOTS);
        System.out.println("Number of sets: " + SETS);
        System.out.println("Number of slots per set: " + SLOTS_PER_SET);
        System.out.println("Address looks like:");
        System.out.println("[   tag: " + TAG_BITS + " bits ][ set:" + SET_BITS + " bits][ offset:" + OFFSET_BITS + " bits]");
        System.out.println("------------------------------");
    }

    private static void initializeAddressFile(String fileName) throws IOException {
        PrintWriter pw = new PrintWriter(new FileWriter(fileName));

        for (int i = 0; i < NUM_ADDRESSES; i++) {
            String zeroes = "";
            for(int j = 0; j < OFFSET_BITS; j++) {
                zeroes += "0";
            }
            String line = randomBinaryNumber(TAG_BITS) + randomBinaryNumber(SET_BITS) + zeroes;
            pw.write(line);
            pw.println();
            pw.flush();
        }
        pw.close();
    }

    private static String randomBinaryNumber(int length) {
        Random rg = new Random();
        StringBuffer retval = new StringBuffer("");
        for(int i = 0; i < length; i++) {
            int n = rg.nextInt(2);
            retval.append(Integer.toString(n));
        }

        return retval.toString();
    }

}

