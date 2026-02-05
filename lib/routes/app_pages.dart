import 'package:get/get.dart';
import 'package:nafa_pro/routes/app_routes.dart';
// AUTH
import 'package:nafa_pro/modules/auth/views/login_view.dart';
import 'package:nafa_pro/modules/auth/bindings/auth_binding.dart';
// DRIVER
import 'package:nafa_pro/modules/driver/safety_check/views/safety_view.dart';
import 'package:nafa_pro/modules/driver/safety_check/bindings/safety_binding.dart';
import 'package:nafa_pro/modules/driver/home/views/driver_home_view.dart';
import 'package:nafa_pro/modules/driver/home/bindings/driver_home_binding.dart';
import 'package:nafa_pro/modules/driver/notifications/views/notifications_view.dart';
import 'package:nafa_pro/modules/driver/profile/history/views/history_view.dart';
import 'package:nafa_pro/modules/driver/profile/performance/views/performance_view.dart';
import 'package:nafa_pro/modules/driver/profile/support/views/support_view.dart';
// MANAGER
import 'package:nafa_pro/modules/manager/root/manager_root_view.dart';
import 'package:nafa_pro/modules/manager/root/manager_root_binding.dart';
import 'package:nafa_pro/modules/manager/orders/dispatch_view.dart';
import 'package:nafa_pro/modules/manager/orders/dispatch_binding.dart';
import 'package:nafa_pro/modules/manager/fleet/views/fleet_view.dart';
import 'package:nafa_pro/modules/manager/fleet/bindings/fleet_binding.dart';
import 'package:nafa_pro/modules/manager/stock/views/stock_view.dart';
import 'package:nafa_pro/modules/manager/stock/bindings/stock_binding.dart';
import 'package:nafa_pro/modules/manager/finance/views/finance_view.dart';
import 'package:nafa_pro/modules/manager/finance/bindings/finance_binding.dart';
import 'package:nafa_pro/modules/manager/settings/views/settings_view.dart';
import 'package:nafa_pro/modules/manager/settings/bindings/settings_binding.dart';
import 'package:nafa_pro/modules/manager/clients/views/clients_view.dart';
import 'package:nafa_pro/modules/manager/clients/bindings/clients_binding.dart';
import '../modules/manager/stock/views/mouvement_binding.dart';
import '../modules/manager/stock/views/mouvement_tab.dart';
import '../modules/manager/stock/views/sessions_tab.dart';
import '../modules/manager/stock/views/session_binding.dart';
import '../modules/manager/stock/mouvement_detail/mouvement_detail_view.dart';
import '../modules/manager/stock/mouvement_detail/mouvement_detail_binding.dart';
import '../modules/manager/stock/detail_session/detail_session_view.dart';
import '../modules/manager/stock/detail_session/detail_session_binding.dart';
import '../modules/manager/stock/details_produit/detail_produit_binding.dart';
import '../modules/manager/stock/details_produit/detail_produit_view.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(name: Routes.LOGIN, page: () => const LoginView(), binding: AuthBinding()),
    // DRIVER
    GetPage(name: Routes.DRIVER_SAFETY, page: () => const SafetyView(), binding: SafetyBinding()),
    GetPage(name: Routes.DRIVER_HOME, page: () => const DriverHomeView(), binding: DriverHomeBinding()),
    GetPage(name: Routes.DRIVER_NOTIFICATIONS, page: () => const NotificationsView()),
    GetPage(name: Routes.DRIVER_HISTORY, page: () => const HistoryView()),
    GetPage(name: Routes.DRIVER_PERFORMANCE, page: () => const PerformanceView()),
    GetPage(name: Routes.DRIVER_SUPPORT, page: () => const SupportView()),
    
    // MANAGER
    GetPage(name: Routes.MANAGER_HOME, page: () => const ManagerRootView(), binding: ManagerRootBinding()),
    GetPage(name: Routes.MANAGER_DISPATCH, page: () => const DispatchView(), binding: DispatchBinding()),
    GetPage(name: Routes.MANAGER_FLEET, page: () => const FleetView(), binding: FleetBinding()),
    GetPage(name: Routes.MANAGER_STOCK, page: () => const StockView(), binding: StockBinding()),
    GetPage(name: Routes.MANAGER_FINANCE, page: () => const FinanceView(), binding: FinanceBinding()),
    GetPage(name: Routes.MANAGER_SETTINGS, page: () => const SettingsView(), binding: SettingsBinding()),
    GetPage(name: Routes.MANAGER_CLIENTS, page: () => const ClientsView(), binding: ClientsBinding()),
    GetPage(name: Routes.MOUVEMENT, page: () => const MouvementTab(), binding: MouvementBinding()),
    GetPage(name: Routes.DETAILMOUVEMENT, page: () => const MouvementDetailView(), binding:MouvementDetailBinding()),
    GetPage(name: Routes.SESSION, page: () => const SessionsTab(), binding:SessionBinding()),
    GetPage(name: Routes.DETAILSESSION, page: () => const DetailSessionView(), binding:DetailSessionBinding()),
    GetPage(name: Routes.DETAILPRODUIT, page: () => const ProduitDetailView(), binding:ProduitDetailBinding()),


  ];
}
