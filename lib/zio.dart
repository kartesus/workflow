// ignore_for_file: annotate_overrides

abstract class ZIO<A> {
  ZIO<B> flatMap<B>(ZIO<B> Function(A) f) => FlatMap(this, f);
  ZIO<Fiber<A>> fork() => Fork(this);
  ZIO<B> map<B>(B Function(A) f) => flatMap((a) => succeedNow(f(a)));
  ZIO<(A, B)> zip<B>(ZIO<B> other) => flatMap((a) => other.map((b) => (a, b)));
  ZIO<B> as<B>(B value) => map((_) => value);
  run(Function(A) callback);
}

class SucceedNow<A> extends ZIO<A> {
  final A value;
  SucceedNow(this.value);
  run(void Function(A) callback) => callback(value);
}

class Succeed<A> extends ZIO<A> {
  final A Function() thunk;
  Succeed(this.thunk);
  run(Function(A) callback) => callback(thunk());
}

class FlatMap<A, B> extends ZIO<B> {
  final ZIO<A> zio;
  final ZIO<B> Function(A) f;
  FlatMap(this.zio, this.f);
  run(Function(B) callback) {
    zio.run((A a) => f(a).run(callback));
  }
}

class Suspend<a> extends ZIO<a> {
  final Function(Function(a)) register;
  Suspend(this.register);
  run(Function(a) callback) {
    register(callback);
  }
}

class Fork<A> extends ZIO<Fiber<A>> {
  final ZIO<A> zio;
  Fork(this.zio);
  run(Function(Fiber<A>) callback) {
    final fiber = Fiber(zio);
    fiber.start();
    callback(fiber);
  }
}

ZIO<A> succeedNow<A>(A value) => SucceedNow(value);
ZIO<A> succeed<A>(A Function() thunk) => Succeed(thunk);
ZIO<A> suspend<A>(Function(Function(A)) register) => Suspend(register);

class Fiber<A> {
  final ZIO<A> zio;
  A? result;
  final callbacks = <Function(A)>[];

  Fiber(this.zio);

  void start() {
    Future(() => zio.run((a) {
          result = a;
          for (var callback in callbacks) {
            callback(a);
          }
        }));
  }

  ZIO<A> join() {
    return result != null
        ? succeedNow(result as A)
        : suspend((complete) => callbacks.add(complete));
  }
}
