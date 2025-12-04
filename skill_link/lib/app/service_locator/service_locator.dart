import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'package:skill_link/cores/network/api_service.dart';

// Auth
import 'package:skill_link/features/auth/data/data_source/local_datasource/user_local_datasource.dart';
import 'package:skill_link/features/auth/data/data_source/remote_datasource/user_remote_datasource.dart';
import 'package:skill_link/features/auth/data/repository/local_repository/user_local_repository.dart';
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

// Property
import 'package:skill_link/features/add_property/data/data_source/property/remote_datasource/property_remote_datasource.dart';
import 'package:skill_link/features/add_property/data/repository/property/remote_repository/property_remote_repository.dart';
import 'package:skill_link/features/add_property/domain/repository/property_repository.dart';
import 'package:skill_link/features/add_property/domain/use_case/property/get_all_properties_usecase.dart';
import 'package:skill_link/features/add_property/domain/use_case/property/add_property_usecase.dart';
import 'package:skill_link/features/add_property/domain/use_case/property/update_property_usecase.dart';
import 'package:skill_link/features/add_property/domain/use_case/property/delete_property_usecase.dart';
import 'package:skill_link/features/add_property/domain/use_case/category/get_all_categories_usecase.dart';
import 'package:skill_link/features/add_property/domain/use_case/category/add_category_usecase.dart';
import 'package:skill_link/features/add_property/presentation/property/view_model/add_property_view_model.dart';

// Category
import 'package:skill_link/features/add_property/data/data_source/category/remote_datasource/category_remote_datasource.dart';
import 'package:skill_link/features/add_property/data/repository/category/remote_repository/category_remote_repository.dart';
import 'package:skill_link/features/add_property/domain/repository/category_repository.dart';

// Cart
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

// Explore
import 'package:skill_link/features/explore/data/data_source/explore_remote_data_source.dart';
import 'package:skill_link/features/explore/data/repository/explore_repository_impl.dart';
import 'package:skill_link/features/explore/domain/repository/explore_repository.dart';
import 'package:skill_link/features/explore/domain/use_case/get_all_properties_usecase.dart';
import 'package:skill_link/features/explore/presentation/bloc/explore_bloc.dart';

// // Chatbot
// import 'package:skill_link/features/chatbot/data/data_source/remote_datasource/chatbot_remote_datasource.dart';
// import 'package:skill_link/features/chatbot/data/repository/chatbot_repository_impl.dart';
// import 'package:skill_link/features/chatbot/domain/repository/chatbot_repository.dart';
// import 'package:skill_link/features/chatbot/domain/use_case/send_chat_query_usecase.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_link/app/shared_pref/token_shared_prefs.dart';

import 'package:skill_link/features/chat/data/data_source/chat_rest_data_source.dart';
import 'package:skill_link/features/chat/data/data_source/chat_socket_data_source.dart';
import 'package:skill_link/features/chat/data/repository/chat_repository.dart';
import 'package:skill_link/features/chat/domain/use_case/chat_usecases.dart';
import 'package:skill_link/features/chat/presentation/bloc/chat_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);
  serviceLocator.registerSingleton<TokenSharedPrefs>(
    TokenSharedPrefs(sharedPreferences: sharedPreferences),
  );
  _initApiService();
  _initAuthAndProfileModules();
  _initPropertyModules();
  _initCartModules();
  _initDashboardModules();
  _initExploreModules();
  _initChatModules();
  //_initChatbotModules();
}

void _initApiService() {
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  serviceLocator.registerLazySingleton<ApiService>(
    () => ApiService(serviceLocator<Dio>(), serviceLocator<TokenSharedPrefs>()),
  );
}

void _initPropertyModules() {
  // --- Property Data Sources ---
  serviceLocator.registerFactory<PropertyRemoteDatasource>(
    () => PropertyRemoteDatasource(dio: serviceLocator<Dio>()),
  );

  serviceLocator.registerFactory<CategoryRemoteDatasource>(
    () => CategoryRemoteDatasource(dio: serviceLocator<Dio>()),
  );

  // --- Property Repositories ---
  serviceLocator.registerFactory<IPropertyRepository>(
    () => PropertyRemoteRepository(
      remoteDataSource: serviceLocator<PropertyRemoteDatasource>(),
    ),
  );

  serviceLocator.registerFactory<ICategoryRepository>(
    () => CategoryRemoteRepository(
      remoteDataSource: serviceLocator<CategoryRemoteDatasource>(),
    ),
  );

  // --- Property Usecases ---
  serviceLocator.registerFactory<GetAllPropertiesUsecase>(
    () => GetAllPropertiesUsecase(serviceLocator<IPropertyRepository>()),
  );

  serviceLocator.registerFactory<AddPropertyUsecase>(
    () => AddPropertyUsecase(repository: serviceLocator<IPropertyRepository>()),
  );

  serviceLocator.registerFactory<UpdatePropertyUsecase>(
    () => UpdatePropertyUsecase(serviceLocator<IPropertyRepository>()),
  );

  serviceLocator.registerFactory<DeletePropertyUsecase>(
    () => DeletePropertyUsecase(serviceLocator<IPropertyRepository>()),
  );

  serviceLocator.registerFactory<GetAllCategoriesUsecase>(
    () => GetAllCategoriesUsecase(serviceLocator<ICategoryRepository>()),
  );

  serviceLocator.registerFactory<AddCategoryUsecase>(
    () => AddCategoryUsecase(serviceLocator<ICategoryRepository>()),
  );

  // --- Property ViewModels/Blocs ---
  serviceLocator.registerFactory<AddPropertyBloc>(
    () => AddPropertyBloc(
      addPropertyUsecase: serviceLocator<AddPropertyUsecase>(),
      updatePropertyUsecase: serviceLocator<UpdatePropertyUsecase>(),
      getAllCategoriesUsecase: serviceLocator<GetAllCategoriesUsecase>(),
      tokenSharedPrefs: serviceLocator<TokenSharedPrefs>(),
    ),
  );
}

void _initCartModules() {
  // --- Cart Data Sources ---
  serviceLocator.registerFactory<CartApiService>(
    () => CartApiServiceImpl(serviceLocator<ApiService>()),
  );

  // --- Cart Repositories ---
  serviceLocator.registerFactory<CartRepository>(
    () => CartRepositoryImpl(serviceLocator<CartApiService>()),
  );

  // --- Cart Usecases ---
  serviceLocator.registerFactory<GetCartUseCase>(
    () => GetCartUseCase(serviceLocator<CartRepository>()),
  );

  serviceLocator.registerFactory<AddToCartUseCase>(
    () => AddToCartUseCase(serviceLocator<CartRepository>()),
  );

  serviceLocator.registerFactory<RemoveFromCartUseCase>(
    () => RemoveFromCartUseCase(serviceLocator<CartRepository>()),
  );

  serviceLocator.registerFactory<ClearCartUseCase>(
    () => ClearCartUseCase(serviceLocator<CartRepository>()),
  );

  // --- Cart Bloc ---
  serviceLocator.registerFactory<CartBloc>(
    () => CartBloc(
      getCartUseCase: serviceLocator<GetCartUseCase>(),
      addToCartUseCase: serviceLocator<AddToCartUseCase>(),
      removeFromCartUseCase: serviceLocator<RemoveFromCartUseCase>(),
      clearCartUseCase: serviceLocator<ClearCartUseCase>(),
    ),
  );
}

void _initAuthAndProfileModules() {
  // --- Data Sources ---
  serviceLocator.registerFactory<UserLocalDatasource>(
    () => UserLocalDatasource(),
  );
  serviceLocator.registerFactory<UserRemoteDatasource>(
    () => UserRemoteDatasource(
      apiService: serviceLocator<ApiService>(),
      sharedPreferences: serviceLocator<SharedPreferences>(),
    ),
  );

  // --- Repositories ---
  serviceLocator.registerFactory<UserLocalRepository>(
    () => UserLocalRepository(),
  );
  serviceLocator.registerFactory<UserRemoteRepository>(
    () => UserRemoteRepository(
      dataSource: serviceLocator<UserRemoteDatasource>(),
      apiService: serviceLocator<ApiService>(),
      tokenSharedPrefs: serviceLocator<TokenSharedPrefs>(),
    ),
  );

  // --- Repository Selection (Concrete Implementation for Interface) ---
  serviceLocator.registerFactory<IUserRepository>(
    () => serviceLocator<UserRemoteRepository>(),
  );

  // --- Usecases ---
  serviceLocator.registerFactory<UserLoginUsecase>(
    () => UserLoginUsecase(userRepository: serviceLocator<IUserRepository>()),
  );
  serviceLocator.registerFactory<UserRegisterUsecase>(
    () =>
        UserRegisterUsecase(userRepository: serviceLocator<IUserRepository>()),
  );
  serviceLocator.registerFactory<UserGetCurrentUsecase>(
    () => UserGetCurrentUsecase(
      userRepository: serviceLocator<IUserRepository>(),
    ),
  );
  serviceLocator.registerFactory<UploadProfilePictureUsecase>(
    () => UploadProfilePictureUsecase(
      userRepository: serviceLocator<IUserRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<UpdateUserProfileUsecase>(
    () => UpdateUserProfileUsecase(serviceLocator<IUserRepository>()),
  );

  // --- ViewModels ---
  serviceLocator.registerFactory<LoginViewModel>(
    () => LoginViewModel(loginUserUseCase: serviceLocator<UserLoginUsecase>()),
  );

  serviceLocator.registerFactory<RegisterUserViewModel>(
    () => RegisterUserViewModel(serviceLocator<UserRegisterUsecase>()),
  );

  serviceLocator.registerFactory<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(apiService: serviceLocator<ApiService>()),
  );
  serviceLocator.registerFactory<ProfileRepositoryImpl>(
    () => ProfileRepositoryImpl(
      remoteDataSource: serviceLocator<ProfileRemoteDataSource>(),
    ),
  );
  serviceLocator.registerFactory<UpdateProfileUsecase>(
    () => UpdateProfileUsecase(
      repository: serviceLocator<ProfileRepositoryImpl>(),
    ),
  );
  serviceLocator.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      userGetCurrentUsecase: serviceLocator<UserGetCurrentUsecase>(),
      uploadProfilePictureUsecase:
          serviceLocator<UploadProfilePictureUsecase>(),
      updateUserProfileUsecase: serviceLocator<UpdateUserProfileUsecase>(),
      updateProfileUsecase: serviceLocator<UpdateProfileUsecase>(),
      tokenSharedPrefs: serviceLocator<TokenSharedPrefs>(),
    ),
  );
}

void _initDashboardModules() {
  // --- Dashboard Data Sources ---
  serviceLocator.registerFactory<DashboardRemoteDatasource>(
    () =>
        DashboardRemoteDatasourceImpl(apiService: serviceLocator<ApiService>()),
  );

  // --- Dashboard Repositories ---
  serviceLocator.registerFactory<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDatasource: serviceLocator<DashboardRemoteDatasource>(),
    ),
  );

  // --- Dashboard Usecases ---
  serviceLocator.registerFactory<GetDashboardPropertiesUsecase>(
    () => GetDashboardPropertiesUsecase(
      repository: serviceLocator<DashboardRepository>(),
    ),
  );

  // --- Dashboard ViewModels/Blocs ---
  serviceLocator.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(
      getDashboardPropertiesUsecase:
          serviceLocator<GetDashboardPropertiesUsecase>(),
    ),
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
  serviceLocator.registerFactory<GetExplorePropertiesUsecase>(
    () => GetExplorePropertiesUsecase(serviceLocator<ExploreRepository>()),
  );

  // --- Explore Bloc ---
  serviceLocator.registerFactory<ExploreBloc>(
    () => ExploreBloc(
      getAllPropertiesUsecase: serviceLocator<GetExplorePropertiesUsecase>(),
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

void setupServiceLocator() {
  serviceLocator.registerLazySingleton<UpdatePropertyUsecase>(
    () => UpdatePropertyUsecase(serviceLocator<IPropertyRepository>()),
  );
  serviceLocator.registerLazySingleton<DeletePropertyUsecase>(
    () => DeletePropertyUsecase(serviceLocator<IPropertyRepository>()),
  );
}
