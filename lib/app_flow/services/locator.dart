import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/ExternalAppManagerService.dart';
import 'package:tournamentmanager/app_flow/services/ImagePickerService.dart';
import 'package:tournamentmanager/app_flow/services/LoaderService.dart';
import 'package:tournamentmanager/app_flow/services/PlacesApiManagerService.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/VerifyMailService.dart';

import 'PocketbaseApiManagerService.dart';


final serviceLocator = GetIt.instance; // GetIt.I is also valid

void serviceLocatorSetUp(){
  //registerSingleton
  //one instance is created and the same instance is returned whenever we call get<T>()
  //registerLazySingleton
  //the object is instantiated only when get<T>() is called the first time
  //registerFactory
  //return a new instance of type T every time we call get<T>()
  //you can’t pass any parameters to the Constructor dynamically using registerFactory()
  //registerFactoryParam
  //Using this method we can instantiate instances that take at most 2 parameters in their constructor.
  //registerFactoryAsync
  //if we need to instantiate an object asynchronously, we can register those kinds of objects using this method

  serviceLocator.registerLazySingleton<ImagePickerService>(() => ImagePickerService());
  serviceLocator.registerLazySingletonAsync<PlacesApiManagerService>(() async {
    final secretManagerService = PlacesApiManagerService();
    await secretManagerService.initialize();
    return secretManagerService;
  });
  serviceLocator.registerLazySingleton<SnackBarService>(() => SnackBarService());
  serviceLocator.registerLazySingleton<LoaderService>(() => LoaderService());
  serviceLocator.registerLazySingleton<VerifyMailService>(() => VerifyMailService());
  serviceLocator.registerLazySingleton<ExternalAppManagerService>(() => ExternalAppManagerService());
  serviceLocator.registerLazySingleton<PocketbaseApiManagerService>(() => PocketbaseApiManagerService());
  //serviceLocator.registerSingleton<Model>(()=> MyModel());
  //serviceLocator.registerFactory<Model>(()=>MyModel());
  //serviceLocator.registerFactoryParam<Person,String,int>((name, age) => Person(name,age));
}