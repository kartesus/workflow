import 'package:workflow/zio.dart' as zio;

class Person {
  String name;
  int age;
  Person(this.name, this.age);

  @override
  String toString() {
    return "Person($name, $age)";
  }
}

void main(List<String> arguments) {
  zio.ZIO<void> printLine(String line) => zio.succeed(() => print(line));

  // zio
  //     .suceedNow(42)
  //     .zip(zio.suceedNow("Alex"))
  //     .flatMap((pair) => printLine(Person(pair.$2, pair.$1).toString()))
  //     .as("Done")
  //     .run((msg) => print(msg));

  final suspended = zio.suspend<int>((complete) {
    print("ASYNC BEGINNETH!");
    Future.delayed(Duration(seconds: 2)).then((_) => complete(42));
  });

  final s1 = suspended.fork();
  final s2 = suspended.fork();

  s1
      .flatMap((f1) => s2.flatMap((f2) => printLine("NICE")
          .flatMap((_) => f1.join().flatMap((a) => f2.join().map((b) => "$a + $b = ${a + b}")))))
      .run((result) => print(result));
}
