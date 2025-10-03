// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as path;
//
// import '../../core/models/monitoring_model.dart';
// import '../../core/utils/validators.dart';
//
// class MonitoringProvider extends ChangeNotifier {
//
//   // Form controllers
//   final mainBuyersController = TextEditingController();
//   final farmBoundaryPolygonController = TextEditingController();
//   final landUseClassificationController = TextEditingController();
//   final accessibilityController = TextEditingController();
//   final proximityToProcessingFacilityController = TextEditingController();
//   final serviceProviderController = TextEditingController();
//   final cooperativesAffiliatedController = TextEditingController();
//   final valueChainLinkagesController = TextEditingController();
//   final visitIdController = TextEditingController();
//   final dateOfVisitController = TextEditingController();
//   final officerNameIdController = TextEditingController();
//   final observationsController = TextEditingController();
//   final issuesIdentifiedController = TextEditingController();
//   final infrastructureIdentifiedController = TextEditingController();
//   final recommendedActionsController = TextEditingController();
//   final followUpStatusController = TextEditingController();
//
//   // State
//   String? _monitoringId;
//   String? _farmerId;
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   // Getters
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//
//   // Form key for validation
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//   // Initialize with farmer ID
//   void initialize(String farmerId, {String? monitoringId}) {
//     _farmerId = farmerId;
//     _monitoringId = monitoringId;
//     if (monitoringId != null) {
//       _loadMonitoringData(monitoringId);
//     }
//   }
//
//   // Load monitoring data by ID
//   Future<void> _loadMonitoringData(String monitoringId) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       final monitoring = await _databaseService.getMonitoring(monitoringId);
//       if (monitoring != null) {
//         _updateControllers(monitoring);
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to load monitoring data: $e';
//       debugPrint(_errorMessage);
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Update controllers with monitoring data
//   void _updateControllers(Monitoring monitoring) {
//     mainBuyersController.text = monitoring.mainBuyers;
//     farmBoundaryPolygonController.text = monitoring.farmBoundaryPolygon;
//     landUseClassificationController.text = monitoring.landUseClassification;
//     accessibilityController.text = monitoring.accessibility;
//     proximityToProcessingFacilityController.text = monitoring.proximityToProcessingFacility;
//     serviceProviderController.text = monitoring.serviceProvider;
//     cooperativesAffiliatedController.text = monitoring.cooperativesAffiliated;
//     valueChainLinkagesController.text = monitoring.valueChainLinkages;
//     visitIdController.text = monitoring.visitId;
//     dateOfVisitController.text = monitoring.dateOfVisit;
//     officerNameIdController.text = monitoring.officerNameId;
//     observationsController.text = monitoring.observations;
//     issuesIdentifiedController.text = monitoring.issuesIdentified;
//     infrastructureIdentifiedController.text = monitoring.infrastructureIdentified;
//     recommendedActionsController.text = monitoring.recommendedActions;
//     followUpStatusController.text = monitoring.followUpStatus;
//   }
//
//   // Validate the form
//   bool validateForm() {
//     if (formKey.currentState?.validate() ?? false) {
//       if (_farmerId == null || _farmerId!.isEmpty) {
//         _errorMessage = 'Farmer ID is required';
//         notifyListeners();
//         return false;
//       }
//       return true;
//     }
//     return false;
//   }
//
//   // Save monitoring data
//   Future<bool> saveMonitoring() async {
//     if (!validateForm()) return false;
//
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();
//
//     try {
//       final monitoring = Monitoring(
//         id: _monitoringId,
//         farmerId: _farmerId!,
//         mainBuyers: mainBuyersController.text.trim(),
//         farmBoundaryPolygon: farmBoundaryPolygonController.text.trim(),
//         landUseClassification: landUseClassificationController.text.trim(),
//         accessibility: accessibilityController.text.trim(),
//         proximityToProcessingFacility: proximityToProcessingFacilityController.text.trim(),
//         serviceProvider: serviceProviderController.text.trim(),
//         cooperativesAffiliated: cooperativesAffiliatedController.text.trim(),
//         valueChainLinkages: valueChainLinkagesController.text.trim(),
//         visitId: visitIdController.text.trim(),
//         dateOfVisit: dateOfVisitController.text.trim(),
//         officerNameId: officerNameIdController.text.trim(),
//         observations: observationsController.text.trim(),
//         issuesIdentified: issuesIdentifiedController.text.trim(),
//         infrastructureIdentified: infrastructureIdentifiedController.text.trim(),
//         recommendedActions: recommendedActionsController.text.trim(),
//         followUpStatus: followUpStatusController.text.trim(),
//       );
//
//       if (_monitoringId == null) {
//         // Create new monitoring record
//         _monitoringId = await _databaseService.insertMonitoring(monitoring);
//       } else {
//         // Update existing monitoring record
//         await _databaseService.updateMonitoring(monitoring);
//       }
//
//       return true;
//     } catch (e) {
//       _errorMessage = 'Failed to save monitoring data: $e';
//       debugPrint(_errorMessage);
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   // Clear the form
//   void clearForm() {
//     _monitoringId = null;
//     mainBuyersController.clear();
//     farmBoundaryPolygonController.clear();
//     landUseClassificationController.clear();
//     accessibilityController.clear();
//     proximityToProcessingFacilityController.clear();
//     serviceProviderController.clear();
//     cooperativesAffiliatedController.clear();
//     valueChainLinkagesController.clear();
//     visitIdController.clear();
//     dateOfVisitController.clear();
//     officerNameIdController.clear();
//     observationsController.clear();
//     issuesIdentifiedController.clear();
//     infrastructureIdentifiedController.clear();
//     recommendedActionsController.clear();
//     followUpStatusController.clear();
//     _errorMessage = null;
//     formKey.currentState?.reset();
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     mainBuyersController.dispose();
//     farmBoundaryPolygonController.dispose();
//     landUseClassificationController.dispose();
//     accessibilityController.dispose();
//     proximityToProcessingFacilityController.dispose();
//     serviceProviderController.dispose();
//     cooperativesAffiliatedController.dispose();
//     valueChainLinkagesController.dispose();
//     visitIdController.dispose();
//     dateOfVisitController.dispose();
//     officerNameIdController.dispose();
//     observationsController.dispose();
//     issuesIdentifiedController.dispose();
//     infrastructureIdentifiedController.dispose();
//     recommendedActionsController.dispose();
//     followUpStatusController.dispose();
//     super.dispose();
//   }
// }
