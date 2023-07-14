// abstract class Workflow<A, B> {
//   (B, Workflow<A, B>) step(A input);
// }

// abstract class Strategy<A, B> {
//   Workflow<A, B> run(Iterable<A> inputs, Workflow<A, B> w);
// }

// class WorkflowFactory<A, B> {
//   Workflow<A, B> succeed(B Function(A) f);
//   Workflow<A, (A, A)> split();
//   Workflow<(A, B), C> join<C>(C Function(A, B) f);
//   Workflow<A, B> loop<S>(S initial, (S, A) Function(S, B) f);
//   Workflow<A, B> then<C>(Workflow<B, C> next);
//   Workflow<(A, C), (B, D)> zip<C, D>(Workflow<C, D> next);
// }

// void main() {}

// Workflow<double, double> computeMean(WorkflowFactory<double, double> wf) {
//   final count = wf.loop(0, (c, _) => (c + 1, c + 1));
//   final sum = wf.loop(0.0, (s, x) => (s + x, s + x));
//   return wf.split().then(sum.zip(count)).then(wf.join((s, c) => s / c));
// }
