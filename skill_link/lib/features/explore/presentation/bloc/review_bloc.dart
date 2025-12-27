import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/features/explore/data/model/review_model.dart';
import 'package:skill_link/features/explore/domain/repository/explore_repository.dart';

// Events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class GetWorkerReviewsEvent extends ReviewEvent {
  final String workerListingId;
  const GetWorkerReviewsEvent(this.workerListingId);
  @override
  List<Object?> get props => [workerListingId];
}

class SubmitReviewEvent extends ReviewEvent {
  final String bookingId;
  final double rating;
  final String? comment;
  const SubmitReviewEvent({required this.bookingId, required this.rating, this.comment});
  @override
  List<Object?> get props => [bookingId, rating, comment];
}

// States
abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}
class ReviewLoading extends ReviewState {}
class ReviewsLoaded extends ReviewState {
  final List<ReviewModel> reviews;
  const ReviewsLoaded(this.reviews);
  @override
  List<Object?> get props => [reviews];
}
class ReviewSuccess extends ReviewState {}
class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ExploreRepository repository;

  ReviewBloc({required this.repository}) : super(ReviewInitial()) {
    on<GetWorkerReviewsEvent>((event, emit) async {
      emit(ReviewLoading());
      final result = await repository.getWorkerReviews(event.workerListingId);
      result.fold(
        (failure) => emit(ReviewError(failure.message)),
        (data) {
          final reviews = data.map((json) => ReviewModel.fromJson(json)).toList();
          emit(ReviewsLoaded(reviews));
        },
      );
    });

    on<SubmitReviewEvent>((event, emit) async {
      emit(ReviewLoading());
      final result = await repository.submitReview(
        bookingId: event.bookingId,
        rating: event.rating,
        comment: event.comment,
      );
      result.fold(
        (failure) => emit(ReviewError(failure.message)),
        (success) => emit(ReviewSuccess()),
      );
    });
  }
}
