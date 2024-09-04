import 'package:fpdart/fpdart.dart';
import 'package:nasa_space_images/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = FutureEither<void>;
