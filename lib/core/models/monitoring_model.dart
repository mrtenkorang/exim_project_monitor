class Monitoring {
  final String? id;
  final String farmerId;
  final String mainBuyers;
  final String farmBoundaryPolygon;
  final String landUseClassification;
  final String accessibility;
  final String proximityToProcessingFacility;
  final String serviceProvider;
  final String cooperativesAffiliated;
  final String valueChainLinkages;
  final String visitId;
  final String dateOfVisit;
  final String officerNameId;
  final String observations;
  final String issuesIdentified;
  final String infrastructureIdentified;
  final String recommendedActions;
  final String followUpStatus;
  final DateTime createdAt;
  final bool isSynced;

  Monitoring({
    this.id,
    required this.farmerId,
    required this.mainBuyers,
    required this.farmBoundaryPolygon,
    required this.landUseClassification,
    required this.accessibility,
    required this.proximityToProcessingFacility,
    required this.serviceProvider,
    required this.cooperativesAffiliated,
    required this.valueChainLinkages,
    required this.visitId,
    required this.dateOfVisit,
    required this.officerNameId,
    required this.observations,
    required this.issuesIdentified,
    required this.infrastructureIdentified,
    required this.recommendedActions,
    required this.followUpStatus,
    DateTime? createdAt,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmerId': farmerId,
      'mainBuyers': mainBuyers,
      'farmBoundaryPolygon': farmBoundaryPolygon,
      'landUseClassification': landUseClassification,
      'accessibility': accessibility,
      'proximityToProcessingFacility': proximityToProcessingFacility,
      'serviceProvider': serviceProvider,
      'cooperativesAffiliated': cooperativesAffiliated,
      'valueChainLinkages': valueChainLinkages,
      'visitId': visitId,
      'dateOfVisit': dateOfVisit,
      'officerNameId': officerNameId,
      'observations': observations,
      'issuesIdentified': issuesIdentified,
      'infrastructureIdentified': infrastructureIdentified,
      'recommendedActions': recommendedActions,
      'followUpStatus': followUpStatus,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Monitoring.fromMap(Map<String, dynamic> map) {
    return Monitoring(
      id: map['id'],
      farmerId: map['farmerId'],
      mainBuyers: map['mainBuyers'],
      farmBoundaryPolygon: map['farmBoundaryPolygon'],
      landUseClassification: map['landUseClassification'],
      accessibility: map['accessibility'],
      proximityToProcessingFacility: map['proximityToProcessingFacility'],
      serviceProvider: map['serviceProvider'],
      cooperativesAffiliated: map['cooperativesAffiliated'],
      valueChainLinkages: map['valueChainLinkages'],
      visitId: map['visitId'],
      dateOfVisit: map['dateOfVisit'],
      officerNameId: map['officerNameId'],
      observations: map['observations'],
      issuesIdentified: map['issuesIdentified'],
      infrastructureIdentified: map['infrastructureIdentified'],
      recommendedActions: map['recommendedActions'],
      followUpStatus: map['followUpStatus'],
      createdAt: DateTime.parse(map['createdAt']),
      isSynced: map['isSynced'] == 1,
    );
  }
}
