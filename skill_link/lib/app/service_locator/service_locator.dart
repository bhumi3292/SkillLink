import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/core/services/notification_service.dart';
import 'package:skill_link/core/services/location_service.dart';
import 'package:skill_link/core/services/socket_notification_service.dart';

import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';

// Auth
import 'package:skill_link/features/auth/data/data_source/local_datasource/user_local_datasource.dart';
import 'package:skill_link/features/auth/data/data_source/remote_datasource/user_remote_datasource.dart';
import 'package:skill_link/features/auth/data/repository/remote_repository/register_remote_repository.dart'; // Assumed to be UserRemoteRepository
import 'package:skill_link/features/auth/domain/repository/user_repository.dart';

import 'package:skill_link/features/auth/domain/use_case/user_login_usecase.dart';
import 'package:skill_link/features/auth/domain/use_case/user_register_usecase.dart';
import 'package:skill_link/features/auth/domain/use_case/user_get_current_usecase.dart';
import 'package:skill_link/features/auth/domain/use_case/update_user_profile_usecase.dart';
import 'package:skill_link/features/auth/presentation/view_model/login_view_model/login_view_model.dart';
import 'package:skill_link/features/auth/presentation/view_model/register_view_model/register_view_model.dart';

// Profile
import 'package:skill_link/features/profile/data/data_source/profile_remote_data_source.dart';
import 'package:skill_link/features/profile/data/repository/profile_repository_impl.dart';
import 'package:skill_link/features/profile/domain/use_case/update_profile_usecase.dart';
import 'package:skill_link/features/profile/presentation/view_model/profile_view_model.dart';
import 'package:skill_link/features/profile/domain/use_case/upload_profile_picture_usecase.dart';

// Add Worker (Worker)
import 'package:skill_link/features/add_worker/data/data_source/worker/remote_datasource/worker_remote_datasource.dart';
import 'package:skill_link/features/add_worker/data/repository/worker/remote_repository/worker_remote_repository.dart';
import 'package:skill_link/features/add_worker/domain/repository/worker_repository.dart';
import 'package:skill_link/features/add_worker/domain/use_case/worker/add_worker_usecase.dart';
import 'package:skill_link/features/add_worker/domain/use_case/category/get_all_categories_usecase.dart';
import 'package:skill_link/features/add_worker/domain/use_case/category/add_category_usecase.dart';
import 'package:skill_link/features/add_worker/data/data_source/category/remote_datasource/category_remote_datasource.dart';
import 'package:skill_link/features/add_worker/data/repository/category/remote_repository/category_remote_repository.dart';
import 'package:skill_link/features/add_worker/domain/repository/category_repository.dart';

// Cart (Favourite)
import 'package:skill_link/features/favourite/data/datasource/cart_api_service.dart';
import 'package:skill_link/features/favourite/data/repository/cart_repository_impl.dart';
import 'package:skill_link/features/favourite/domain/repository/cart_repository.dart';
import 'package:skill_link/features/favourite/domain/usecase/get_cart_usecase.dart';
import 'package:skill_link/features/favourite/domain/usecase/add_to_cart_usecase.dart';
import 'package:skill_link/features/favourite/domain/usecase/remove_from_cart_usecase.dart';
import 'package:skill_link/features/favourite/domain/usecase/clear_cart_usecase.dart';
import 'package:skill_link/features/favourite/presentation/bloc/cart_bloc.dart';

// Dashboard
import 'package:skill_link/features/dashbaord/data/data_source/remote_datasource/dashboard_remote_datasource.dart';
import 'package:skill_link/features/dashbaord/data/repository/dashboard_repository_impl.dart';
import 'package:skill_link/features/dashbaord/domain/repository/dashboard_repository.dart';
import 'package:skill_link/features/dashbaord/domain/use_case/get_dashboard_properties_usecase.dart';
import 'package:skill_link/features/dashbaord/presentation/view_model/dashboard_view_model.dart';
// Note: Dashboard might rely on user usecases too for greeting

// Explore
import 'package:skill_link/features/explore/data/data_source/explore_remote_data_source.dart';
import 'package:skill_link/features/explore/data/repository/explore_repository_impl.dart';
import 'package:skill_link/features/explore/domain/repository/explore_repository.dart';
import 'package:skill_link/features/explore/domain/use_case/get_all_workers_usecase.dart';
import 'package:skill_link/features/explore/presentation/bloc/explore_bloc.dart';

// Chat
import 'package:skill_link/features/chat/data/data_source/chat_rest_data_source.dart';
import 'package:skill_link/features/chat/data/data_source/chat_socket_data_source.dart';
import 'package:skill_link/features/chat/data/repository/chat_repository.dart'; // Ensure this file exists and exports the repository interface
// import 'package:skill_link/features/chat/data/repository/chat_repository_impl.dart'; // Removed unused import
// Note: Imports for Chat usecases were implicit in original, I'll make them explicit if needed OR rely on default exports
import 'package:skill_link/features/chat/domain/use_case/chat_usecases.dart'; // Assuming a barrel file or individual files
import 'package:skill_link/features/chat/presentation/bloc/chat_bloc.dart';

// Booking
import 'package:skill_link/features/booking/data/data_sources/booking_remote_data_source.dart';
import 'package:skill_link/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:skill_link/features/booking/domain/repositories/booking_repository.dart';
import 'package:skill_link/features/booking/presentation/bloc/booking_bloc.dart';

// Notification
import 'package:skill_link/features/notification/data/datasource/notification_remote_datasource.dart';
import 'package:skill_link/features/notification/data/repository/notification_repository_impl.dart';
import 'package:skill_link/features/notification/domain/repository/notification_repository.dart';
import 'package:skill_link/features/notification/presentation/bloc/notification_bloc.dart';

// Payment
import 'package:skill_link/features/payment/data/data_source/payment_remote_data_source.dart';
import 'package:skill_link/features/payment/data/repository/payment_repository_impl.dart';
import 'package:skill_link/features/payment/domain/repository/payment_repository.dart';
import 'package:skill_link/features/payment/domain/use_case/payment_usecases.dart';
import 'package:skill_link/features/payment/presentation/bloc/payment_bloc.dart';

// Admin
import 'package:skill_link/features/admin/data/data_source/admin_remote_datasource.dart';
import 'package:skill_link/features/admin/domain/repository/admin_repository.dart';
import 'package:skill_link/features/admin/data/repository/admin_repository_impl.dart';
import 'package:skill_link/features/admin/presentation/view_model/admin_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // --- External ---
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  serviceLocator.registerLazySingleton<TokenSharedPrefs>(
    () => TokenSharedPrefs(sharedPreferences: serviceLocator()),
  );

  // --- Core ---
  serviceLocator.registerLazySingleton<ApiService>(
    () => ApiService(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  ); // Assuming constructor
  serviceLocator.registerLazySingleton<LocationService>(
    () => LocationService(),
  );
  serviceLocator.registerLazySingleton<SocketNotificationService>(
    () => SocketNotificationService(),
  );

  // --- Modules ---
  _initAuthModules();
  _initProfileModules();
  _initAddWorkerModules();
  _initFavouriteModules();
  _initDashboardModules();
  _initExploreModules();
  _initChatModules();
  _initBookingModules();
  _initNotificationModules();
  _initPaymentModules();
  _initAdminModules();
}

void _initAuthModules() {
  // Data Sources
  serviceLocator.registerLazySingleton<UserLocalDatasource>(
    () => UserLocalDatasource(),
  );
  serviceLocator.registerLazySingleton<UserRemoteDatasource>(
    () => UserRemoteDatasource(
      apiService: serviceLocator(),
      sharedPreferences: serviceLocator(),
    ),
  );

  // Repository
  serviceLocator.registerLazySingleton<IUserRepository>(
    () => UserRemoteRepository(
      dataSource: serviceLocator(),
      tokenSharedPrefs: serviceLocator(),
    ),
  );

  // Usecases
  serviceLocator.registerLazySingleton<UserLoginUsecase>(
    () => UserLoginUsecase(userRepository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<UserRegisterUsecase>(
    () => UserRegisterUsecase(userRepository: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<UserGetCurrentUsecase>(
    () => UserGetCurrentUsecase(
      userRepository: serviceLocator(),
    ), // Needs repository
  );
  serviceLocator.registerLazySingleton<UpdateUserProfileUsecase>(
    () => UpdateUserProfileUsecase(serviceLocator()),
  );

  // Blocs / ViewModels
  serviceLocator.registerFactory<LoginViewModel>(
    () => LoginViewModel(loginUserUseCase: serviceLocator()),
  );
  serviceLocator.registerFactory<RegisterUserViewModel>(
    () => RegisterUserViewModel(serviceLocator()),
  );
}

void _initProfileModules() {
  serviceLocator.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(apiService: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<ProfileRepositoryImpl>(
    () => ProfileRepositoryImpl(remoteDataSource: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<UpdateProfileUsecase>(
    () => UpdateProfileUsecase(
      repository: serviceLocator<ProfileRepositoryImpl>(),
    ),
  );
  serviceLocator.registerLazySingleton<UploadProfilePictureUsecase>(
    () => UploadProfilePictureUsecase(
      userRepository: serviceLocator<IUserRepository>(),
    ),
  );

  serviceLocator.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      updateProfileUsecase: serviceLocator(),
      uploadProfilePictureUsecase: serviceLocator(),
      userGetCurrentUsecase: serviceLocator(),
      updateUserProfileUsecase: serviceLocator(),
      tokenSharedPrefs: serviceLocator(),
    ),
  );
}

void _initAddWorkerModules() {
  // Worker
  serviceLocator.registerLazySingleton<WorkerRemoteDatasource>(
    () => WorkerRemoteDatasource(dio: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<IWorkerRepository>(
    () => WorkerRemoteRepository(
      remoteDataSource: serviceLocator<WorkerRemoteDatasource>(),
    ),
  );

  // Category
  serviceLocator.registerLazySingleton<CategoryRemoteDatasource>(
    () => CategoryRemoteDatasource(dio: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<ICategoryRepository>(
    () => CategoryRemoteRepository(
      remoteDataSource: serviceLocator<CategoryRemoteDatasource>(),
    ),
  );

  // UseCases
  serviceLocator.registerLazySingleton<GetAllCategoriesUsecase>(
    () => GetAllCategoriesUsecase(serviceLocator<ICategoryRepository>()),
  );
  serviceLocator.registerLazySingleton<AddWorkerUsecase>(
    () => AddWorkerUsecase(repository: serviceLocator<IWorkerRepository>()),
  );
  serviceLocator.registerLazySingleton<AddCategoryUsecase>(
    () => AddCategoryUsecase(serviceLocator<ICategoryRepository>()),
  );
}

void _initFavouriteModules() {
  serviceLocator.registerLazySingleton<CartApiService>(
    () => CartApiServiceImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerLazySingleton<GetCartUseCase>(
    () => GetCartUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<AddToCartUseCase>(
    () => AddToCartUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<RemoveFromCartUseCase>(
    () => RemoveFromCartUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<ClearCartUseCase>(
    () => ClearCartUseCase(serviceLocator()),
  );

  serviceLocator.registerFactory<CartBloc>(
    () => CartBloc(
      getCartUseCase: serviceLocator(),
      addToCartUseCase: serviceLocator(),
      removeFromCartUseCase: serviceLocator(),
      clearCartUseCase: serviceLocator(),
    ),
  );
}

void _initDashboardModules() {
  serviceLocator.registerLazySingleton<DashboardRemoteDatasource>(
    () => DashboardRemoteDatasourceImpl(apiService: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDatasource: serviceLocator<DashboardRemoteDatasource>(),
    ),
  );
  serviceLocator.registerLazySingleton<GetDashboardPropertiesUsecase>(
    () => GetDashboardPropertiesUsecase(repository: serviceLocator()),
  );

  serviceLocator.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(getDashboardPropertiesUsecase: serviceLocator()),
  );
}

void _initExploreModules() {
  // --- Explore Data Sources ---
  serviceLocator.registerFactory<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceImpl(serviceLocator<ApiService>()),
  );

  // --- Explore Repositories ---
  serviceLocator.registerFactory<ExploreRepository>(
    () => ExploreRepositoryImpl(serviceLocator<ExploreRemoteDataSource>()),
  );

  // --- Explore Usecases ---
  serviceLocator.registerFactory<GetAllWorkersUsecase>(
    () => GetAllWorkersUsecase(serviceLocator<ExploreRepository>()),
  );

  // --- Explore Bloc ---
  serviceLocator.registerFactory<ExploreBloc>(
    () => ExploreBloc(
      getAllWorkersUsecase: serviceLocator<GetAllWorkersUsecase>(),
    ),
  );
}

void _initChatModules() {
  serviceLocator.registerLazySingleton<ChatRestDataSource>(
    () => ChatRestDataSource(dio: serviceLocator<Dio>()),
  );
  serviceLocator.registerLazySingleton<ChatSocketDataSource>(
    () => ChatSocketDataSource(),
  );
  // Assuming ChatRepository is the interface and ChatRepositoryImpl is the implementation
  // BUT the original code had ChatRepository as the class being instantiated.
  // I will follow the original code pattern for Chat.
  serviceLocator.registerLazySingleton<ChatRepository>(
    () => ChatRepository(
      restDataSource: serviceLocator<ChatRestDataSource>(),
      socketDataSource: serviceLocator<ChatSocketDataSource>(),
    ),
  );
  serviceLocator.registerFactory<GetMyChatsUsecase>(
    () => GetMyChatsUsecase(serviceLocator<ChatRepository>()),
  );
  serviceLocator.registerFactory<CreateOrGetChatUsecase>(
    () => CreateOrGetChatUsecase(serviceLocator<ChatRepository>()),
  );
  serviceLocator.registerFactory<GetChatByIdUsecase>(
    () => GetChatByIdUsecase(serviceLocator<ChatRepository>()),
  );
  serviceLocator.registerFactory<GetMessagesForChatUsecase>(
    () => GetMessagesForChatUsecase(serviceLocator<ChatRepository>()),
  );
  serviceLocator.registerFactory<SendMessageUsecase>(
    () => SendMessageUsecase(serviceLocator<ChatRepository>()),
  );
  serviceLocator.registerFactory<ListenForNewMessagesUsecase>(
    () => ListenForNewMessagesUsecase(serviceLocator<ChatRepository>()),
  );
  serviceLocator.registerFactory<ConnectSocketUsecase>(
    () => ConnectSocketUsecase(serviceLocator<ChatRepository>()),
  );
  serviceLocator.registerFactory<DisconnectSocketUsecase>(
    () => DisconnectSocketUsecase(serviceLocator<ChatRepository>()),
  );
  serviceLocator.registerFactory<JoinChatUsecase>(
    () => JoinChatUsecase(serviceLocator<ChatRepository>()),
  );
  serviceLocator.registerFactory<ChatBloc>(
    () => ChatBloc(
      getMyChatsUsecase: serviceLocator<GetMyChatsUsecase>(),
      createOrGetChatUsecase: serviceLocator<CreateOrGetChatUsecase>(),
      getChatByIdUsecase: serviceLocator<GetChatByIdUsecase>(),
      getMessagesForChatUsecase: serviceLocator<GetMessagesForChatUsecase>(),
      sendMessageUsecase: serviceLocator<SendMessageUsecase>(),
      listenForNewMessagesUsecase:
          serviceLocator<ListenForNewMessagesUsecase>(),
      connectSocketUsecase: serviceLocator<ConnectSocketUsecase>(),
      disconnectSocketUsecase: serviceLocator<DisconnectSocketUsecase>(),
      joinChatUsecase: serviceLocator<JoinChatUsecase>(),
    ),
  );
}

void _initBookingModules() {
  // Data Source
  serviceLocator.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(dio: serviceLocator()),
  );

  // Repository
  serviceLocator.registerLazySingleton<IBookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: serviceLocator()),
  );

  // Bloc
  serviceLocator.registerFactory<BookingBloc>(
    () => BookingBloc(bookingRepository: serviceLocator()),
  );
}

void _initNotificationModules() {
  serviceLocator.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(serviceLocator<ApiService>()),
  );
  serviceLocator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: serviceLocator()),
  );
  serviceLocator.registerFactory<NotificationBloc>(
    () => NotificationBloc(repository: serviceLocator()),
  );
}

void _initPaymentModules() {
  // Data Source
  serviceLocator.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(serviceLocator<ApiService>()),
  );

  // Repository
  serviceLocator.registerLazySingleton<IPaymentRepository>(
    () => PaymentRepositoryImpl(serviceLocator<PaymentRemoteDataSource>()),
  );

  // UseCases
  serviceLocator.registerLazySingleton<InitiatePaymentUseCase>(
    () => InitiatePaymentUseCase(serviceLocator<IPaymentRepository>()),
  );
  serviceLocator.registerLazySingleton<VerifyPaymentUseCase>(
    () => VerifyPaymentUseCase(serviceLocator<IPaymentRepository>()),
  );
  serviceLocator.registerLazySingleton<GetPaymentHistoryUseCase>(
    () => GetPaymentHistoryUseCase(serviceLocator<IPaymentRepository>()),
  );

  // Bloc
  serviceLocator.registerFactory<PaymentBloc>(
    () => PaymentBloc(
      initiatePaymentUseCase: serviceLocator(),
      verifyPaymentUseCase: serviceLocator(),
      getPaymentHistoryUseCase: serviceLocator(),
    ),
  );
}

void _initAdminModules() {
  serviceLocator.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(serviceLocator<ApiService>()),
  );
  serviceLocator.registerLazySingleton<IAdminRepository>(
    () => AdminRepositoryImpl(serviceLocator<AdminRemoteDataSource>()),
  );
  serviceLocator.registerFactory<AdminCubit>(
    () => AdminCubit(serviceLocator<IAdminRepository>()),
  );
}
