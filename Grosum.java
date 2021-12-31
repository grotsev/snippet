import java.util.function.ToLongFunction;
import java.util.stream.LongStream;

public class Grosum {
    static long usualSum(LongStream changes) {
        return changes.reduce(0, (a, b) -> a + b);
    }

    static long nonNegativeSum(LongStream changes) {
        return changes.reduce(0, (a, b) -> Math.max(0, a + b));
    }

    static LongStream changes() {
        return LongStream
                .range(1, 1000_000_000)
                .map(i -> (i * 137) % 199 - 99);
    }

    static void bench(ToLongFunction<LongStream> function, LongStream changes) {
        long start = System.currentTimeMillis();
        long result = function.applyAsLong(changes);
        long end = System.currentTimeMillis();
        System.out.printf("%4sms: %s\n", end - start, result);
    }

    static final class Gro {
        private long fall;
        private long grow;
    }

    static long grosum(LongStream changes) {
        return changes.collect(Gro::new, Grosum::accumulator, Grosum::combiner).grow;
    }

    static void accumulator(Gro a, long value) {
        a.grow += value;
        if (a.grow < 0) {
            a.fall -= a.grow;
            a.grow = 0;
        }
    }

    static void combiner(Gro a, Gro b) {
        if (a.grow < b.fall) {
            a.fall += b.fall - a.grow;
            a.grow = b.grow;
        } else {
            a.grow += b.grow - b.fall;
        }
    }

    public static void main(String[] args) {
        bench(Grosum::usualSum, changes());
        bench(Grosum::usualSum, changes().parallel());
        bench(Grosum::nonNegativeSum, changes());
        bench(Grosum::nonNegativeSum, changes().parallel());
        bench(Grosum::grosum, changes());
        bench(Grosum::grosum, changes().parallel());
    }
}
