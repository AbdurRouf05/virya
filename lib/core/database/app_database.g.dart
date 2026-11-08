// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gearIdMeta = const VerificationMeta('gearId');
  @override
  late final GeneratedColumn<String> gearId = GeneratedColumn<String>(
    'gear_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sportTypeMeta = const VerificationMeta(
    'sportType',
  );
  @override
  late final GeneratedColumn<String> sportType = GeneratedColumn<String>(
    'sport_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDistanceMetersMeta =
      const VerificationMeta('totalDistanceMeters');
  @override
  late final GeneratedColumn<double> totalDistanceMeters =
      GeneratedColumn<double>(
        'total_distance_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _elapsedTimeSecondsMeta =
      const VerificationMeta('elapsedTimeSeconds');
  @override
  late final GeneratedColumn<int> elapsedTimeSeconds = GeneratedColumn<int>(
    'elapsed_time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movingTimeSecondsMeta = const VerificationMeta(
    'movingTimeSeconds',
  );
  @override
  late final GeneratedColumn<int> movingTimeSeconds = GeneratedColumn<int>(
    'moving_time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elevationGainMetersMeta =
      const VerificationMeta('elevationGainMeters');
  @override
  late final GeneratedColumn<double> elevationGainMeters =
      GeneratedColumn<double>(
        'elevation_gain_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _elevationLossMetersMeta =
      const VerificationMeta('elevationLossMeters');
  @override
  late final GeneratedColumn<double> elevationLossMeters =
      GeneratedColumn<double>(
        'elevation_loss_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _maxElevationMetersMeta =
      const VerificationMeta('maxElevationMeters');
  @override
  late final GeneratedColumn<double> maxElevationMeters =
      GeneratedColumn<double>(
        'max_elevation_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _minElevationMetersMeta =
      const VerificationMeta('minElevationMeters');
  @override
  late final GeneratedColumn<double> minElevationMeters =
      GeneratedColumn<double>(
        'min_elevation_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _avgSpeedMpsMeta = const VerificationMeta(
    'avgSpeedMps',
  );
  @override
  late final GeneratedColumn<double> avgSpeedMps = GeneratedColumn<double>(
    'avg_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _maxSpeedMpsMeta = const VerificationMeta(
    'maxSpeedMps',
  );
  @override
  late final GeneratedColumn<double> maxSpeedMps = GeneratedColumn<double>(
    'max_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _avgGapMpsMeta = const VerificationMeta(
    'avgGapMps',
  );
  @override
  late final GeneratedColumn<double> avgGapMps = GeneratedColumn<double>(
    'avg_gap_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgCadenceMeta = const VerificationMeta(
    'avgCadence',
  );
  @override
  late final GeneratedColumn<int> avgCadence = GeneratedColumn<int>(
    'avg_cadence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avg_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHeartRateMeta = const VerificationMeta(
    'maxHeartRate',
  );
  @override
  late final GeneratedColumn<int> maxHeartRate = GeneratedColumn<int>(
    'max_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedEnergyKjMeta = const VerificationMeta(
    'estimatedEnergyKj',
  );
  @override
  late final GeneratedColumn<int> estimatedEnergyKj = GeneratedColumn<int>(
    'estimated_energy_kj',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gravelPercentageMeta = const VerificationMeta(
    'gravelPercentage',
  );
  @override
  late final GeneratedColumn<double> gravelPercentage = GeneratedColumn<double>(
    'gravel_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _asphaltPercentageMeta = const VerificationMeta(
    'asphaltPercentage',
  );
  @override
  late final GeneratedColumn<double> asphaltPercentage =
      GeneratedColumn<double>(
        'asphalt_percentage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _relativeEffortMeta = const VerificationMeta(
    'relativeEffort',
  );
  @override
  late final GeneratedColumn<double> relativeEffort = GeneratedColumn<double>(
    'relative_effort',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _gritScoreMeta = const VerificationMeta(
    'gritScore',
  );
  @override
  late final GeneratedColumn<double> gritScore = GeneratedColumn<double>(
    'grit_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _avgPowerWMeta = const VerificationMeta(
    'avgPowerW',
  );
  @override
  late final GeneratedColumn<double> avgPowerW = GeneratedColumn<double>(
    'avg_power_w',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('recorded'),
  );
  static const VerificationMeta _primaryPhotoPathMeta = const VerificationMeta(
    'primaryPhotoPath',
  );
  @override
  late final GeneratedColumn<String> primaryPhotoPath = GeneratedColumn<String>(
    'primary_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    gearId,
    title,
    description,
    sportType,
    status,
    startTime,
    endTime,
    totalDistanceMeters,
    elapsedTimeSeconds,
    movingTimeSeconds,
    elevationGainMeters,
    elevationLossMeters,
    maxElevationMeters,
    minElevationMeters,
    avgSpeedMps,
    maxSpeedMps,
    avgGapMps,
    avgCadence,
    avgHeartRate,
    maxHeartRate,
    estimatedEnergyKj,
    gravelPercentage,
    asphaltPercentage,
    relativeEffort,
    gritScore,
    avgPowerW,
    source,
    primaryPhotoPath,
    isFavorite,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('gear_id')) {
      context.handle(
        _gearIdMeta,
        gearId.isAcceptableOrUnknown(data['gear_id']!, _gearIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('sport_type')) {
      context.handle(
        _sportTypeMeta,
        sportType.isAcceptableOrUnknown(data['sport_type']!, _sportTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sportTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('total_distance_meters')) {
      context.handle(
        _totalDistanceMetersMeta,
        totalDistanceMeters.isAcceptableOrUnknown(
          data['total_distance_meters']!,
          _totalDistanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_time_seconds')) {
      context.handle(
        _elapsedTimeSecondsMeta,
        elapsedTimeSeconds.isAcceptableOrUnknown(
          data['elapsed_time_seconds']!,
          _elapsedTimeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('moving_time_seconds')) {
      context.handle(
        _movingTimeSecondsMeta,
        movingTimeSeconds.isAcceptableOrUnknown(
          data['moving_time_seconds']!,
          _movingTimeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('elevation_gain_meters')) {
      context.handle(
        _elevationGainMetersMeta,
        elevationGainMeters.isAcceptableOrUnknown(
          data['elevation_gain_meters']!,
          _elevationGainMetersMeta,
        ),
      );
    }
    if (data.containsKey('elevation_loss_meters')) {
      context.handle(
        _elevationLossMetersMeta,
        elevationLossMeters.isAcceptableOrUnknown(
          data['elevation_loss_meters']!,
          _elevationLossMetersMeta,
        ),
      );
    }
    if (data.containsKey('max_elevation_meters')) {
      context.handle(
        _maxElevationMetersMeta,
        maxElevationMeters.isAcceptableOrUnknown(
          data['max_elevation_meters']!,
          _maxElevationMetersMeta,
        ),
      );
    }
    if (data.containsKey('min_elevation_meters')) {
      context.handle(
        _minElevationMetersMeta,
        minElevationMeters.isAcceptableOrUnknown(
          data['min_elevation_meters']!,
          _minElevationMetersMeta,
        ),
      );
    }
    if (data.containsKey('avg_speed_mps')) {
      context.handle(
        _avgSpeedMpsMeta,
        avgSpeedMps.isAcceptableOrUnknown(
          data['avg_speed_mps']!,
          _avgSpeedMpsMeta,
        ),
      );
    }
    if (data.containsKey('max_speed_mps')) {
      context.handle(
        _maxSpeedMpsMeta,
        maxSpeedMps.isAcceptableOrUnknown(
          data['max_speed_mps']!,
          _maxSpeedMpsMeta,
        ),
      );
    }
    if (data.containsKey('avg_gap_mps')) {
      context.handle(
        _avgGapMpsMeta,
        avgGapMps.isAcceptableOrUnknown(data['avg_gap_mps']!, _avgGapMpsMeta),
      );
    }
    if (data.containsKey('avg_cadence')) {
      context.handle(
        _avgCadenceMeta,
        avgCadence.isAcceptableOrUnknown(data['avg_cadence']!, _avgCadenceMeta),
      );
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('max_heart_rate')) {
      context.handle(
        _maxHeartRateMeta,
        maxHeartRate.isAcceptableOrUnknown(
          data['max_heart_rate']!,
          _maxHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('estimated_energy_kj')) {
      context.handle(
        _estimatedEnergyKjMeta,
        estimatedEnergyKj.isAcceptableOrUnknown(
          data['estimated_energy_kj']!,
          _estimatedEnergyKjMeta,
        ),
      );
    }
    if (data.containsKey('gravel_percentage')) {
      context.handle(
        _gravelPercentageMeta,
        gravelPercentage.isAcceptableOrUnknown(
          data['gravel_percentage']!,
          _gravelPercentageMeta,
        ),
      );
    }
    if (data.containsKey('asphalt_percentage')) {
      context.handle(
        _asphaltPercentageMeta,
        asphaltPercentage.isAcceptableOrUnknown(
          data['asphalt_percentage']!,
          _asphaltPercentageMeta,
        ),
      );
    }
    if (data.containsKey('relative_effort')) {
      context.handle(
        _relativeEffortMeta,
        relativeEffort.isAcceptableOrUnknown(
          data['relative_effort']!,
          _relativeEffortMeta,
        ),
      );
    }
    if (data.containsKey('grit_score')) {
      context.handle(
        _gritScoreMeta,
        gritScore.isAcceptableOrUnknown(data['grit_score']!, _gritScoreMeta),
      );
    }
    if (data.containsKey('avg_power_w')) {
      context.handle(
        _avgPowerWMeta,
        avgPowerW.isAcceptableOrUnknown(data['avg_power_w']!, _avgPowerWMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('primary_photo_path')) {
      context.handle(
        _primaryPhotoPathMeta,
        primaryPhotoPath.isAcceptableOrUnknown(
          data['primary_photo_path']!,
          _primaryPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      gearId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gear_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      sportType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sport_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      totalDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_distance_meters'],
      )!,
      elapsedTimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_time_seconds'],
      )!,
      movingTimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moving_time_seconds'],
      )!,
      elevationGainMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_meters'],
      )!,
      elevationLossMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_loss_meters'],
      )!,
      maxElevationMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_elevation_meters'],
      )!,
      minElevationMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_elevation_meters'],
      )!,
      avgSpeedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_speed_mps'],
      )!,
      maxSpeedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_speed_mps'],
      )!,
      avgGapMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_gap_mps'],
      ),
      avgCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_cadence'],
      ),
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_heart_rate'],
      ),
      maxHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_heart_rate'],
      ),
      estimatedEnergyKj: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_energy_kj'],
      ),
      gravelPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gravel_percentage'],
      )!,
      asphaltPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}asphalt_percentage'],
      )!,
      relativeEffort: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}relative_effort'],
      )!,
      gritScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grit_score'],
      )!,
      avgPowerW: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_power_w'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      primaryPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_photo_path'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }
}

class Activity extends DataClass implements Insertable<Activity> {
  final String id;
  final String? userId;
  final String? gearId;
  final String title;
  final String? description;
  final String sportType;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final double totalDistanceMeters;
  final int elapsedTimeSeconds;
  final int movingTimeSeconds;
  final double elevationGainMeters;
  final double elevationLossMeters;
  final double maxElevationMeters;
  final double minElevationMeters;
  final double avgSpeedMps;
  final double maxSpeedMps;
  final double? avgGapMps;
  final int? avgCadence;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final int? estimatedEnergyKj;
  final double gravelPercentage;
  final double asphaltPercentage;
  final double relativeEffort;
  final double gritScore;
  final double? avgPowerW;
  final String source;
  final String? primaryPhotoPath;
  final bool isFavorite;
  final DateTime updatedAt;
  const Activity({
    required this.id,
    this.userId,
    this.gearId,
    required this.title,
    this.description,
    required this.sportType,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.totalDistanceMeters,
    required this.elapsedTimeSeconds,
    required this.movingTimeSeconds,
    required this.elevationGainMeters,
    required this.elevationLossMeters,
    required this.maxElevationMeters,
    required this.minElevationMeters,
    required this.avgSpeedMps,
    required this.maxSpeedMps,
    this.avgGapMps,
    this.avgCadence,
    this.avgHeartRate,
    this.maxHeartRate,
    this.estimatedEnergyKj,
    required this.gravelPercentage,
    required this.asphaltPercentage,
    required this.relativeEffort,
    required this.gritScore,
    this.avgPowerW,
    required this.source,
    this.primaryPhotoPath,
    required this.isFavorite,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || gearId != null) {
      map['gear_id'] = Variable<String>(gearId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sport_type'] = Variable<String>(sportType);
    map['status'] = Variable<String>(status);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['total_distance_meters'] = Variable<double>(totalDistanceMeters);
    map['elapsed_time_seconds'] = Variable<int>(elapsedTimeSeconds);
    map['moving_time_seconds'] = Variable<int>(movingTimeSeconds);
    map['elevation_gain_meters'] = Variable<double>(elevationGainMeters);
    map['elevation_loss_meters'] = Variable<double>(elevationLossMeters);
    map['max_elevation_meters'] = Variable<double>(maxElevationMeters);
    map['min_elevation_meters'] = Variable<double>(minElevationMeters);
    map['avg_speed_mps'] = Variable<double>(avgSpeedMps);
    map['max_speed_mps'] = Variable<double>(maxSpeedMps);
    if (!nullToAbsent || avgGapMps != null) {
      map['avg_gap_mps'] = Variable<double>(avgGapMps);
    }
    if (!nullToAbsent || avgCadence != null) {
      map['avg_cadence'] = Variable<int>(avgCadence);
    }
    if (!nullToAbsent || avgHeartRate != null) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    }
    if (!nullToAbsent || maxHeartRate != null) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate);
    }
    if (!nullToAbsent || estimatedEnergyKj != null) {
      map['estimated_energy_kj'] = Variable<int>(estimatedEnergyKj);
    }
    map['gravel_percentage'] = Variable<double>(gravelPercentage);
    map['asphalt_percentage'] = Variable<double>(asphaltPercentage);
    map['relative_effort'] = Variable<double>(relativeEffort);
    map['grit_score'] = Variable<double>(gritScore);
    if (!nullToAbsent || avgPowerW != null) {
      map['avg_power_w'] = Variable<double>(avgPowerW);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || primaryPhotoPath != null) {
      map['primary_photo_path'] = Variable<String>(primaryPhotoPath);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      gearId: gearId == null && nullToAbsent
          ? const Value.absent()
          : Value(gearId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sportType: Value(sportType),
      status: Value(status),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      totalDistanceMeters: Value(totalDistanceMeters),
      elapsedTimeSeconds: Value(elapsedTimeSeconds),
      movingTimeSeconds: Value(movingTimeSeconds),
      elevationGainMeters: Value(elevationGainMeters),
      elevationLossMeters: Value(elevationLossMeters),
      maxElevationMeters: Value(maxElevationMeters),
      minElevationMeters: Value(minElevationMeters),
      avgSpeedMps: Value(avgSpeedMps),
      maxSpeedMps: Value(maxSpeedMps),
      avgGapMps: avgGapMps == null && nullToAbsent
          ? const Value.absent()
          : Value(avgGapMps),
      avgCadence: avgCadence == null && nullToAbsent
          ? const Value.absent()
          : Value(avgCadence),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      maxHeartRate: maxHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHeartRate),
      estimatedEnergyKj: estimatedEnergyKj == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedEnergyKj),
      gravelPercentage: Value(gravelPercentage),
      asphaltPercentage: Value(asphaltPercentage),
      relativeEffort: Value(relativeEffort),
      gritScore: Value(gritScore),
      avgPowerW: avgPowerW == null && nullToAbsent
          ? const Value.absent()
          : Value(avgPowerW),
      source: Value(source),
      primaryPhotoPath: primaryPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryPhotoPath),
      isFavorite: Value(isFavorite),
      updatedAt: Value(updatedAt),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      gearId: serializer.fromJson<String?>(json['gearId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      sportType: serializer.fromJson<String>(json['sportType']),
      status: serializer.fromJson<String>(json['status']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      totalDistanceMeters: serializer.fromJson<double>(
        json['totalDistanceMeters'],
      ),
      elapsedTimeSeconds: serializer.fromJson<int>(json['elapsedTimeSeconds']),
      movingTimeSeconds: serializer.fromJson<int>(json['movingTimeSeconds']),
      elevationGainMeters: serializer.fromJson<double>(
        json['elevationGainMeters'],
      ),
      elevationLossMeters: serializer.fromJson<double>(
        json['elevationLossMeters'],
      ),
      maxElevationMeters: serializer.fromJson<double>(
        json['maxElevationMeters'],
      ),
      minElevationMeters: serializer.fromJson<double>(
        json['minElevationMeters'],
      ),
      avgSpeedMps: serializer.fromJson<double>(json['avgSpeedMps']),
      maxSpeedMps: serializer.fromJson<double>(json['maxSpeedMps']),
      avgGapMps: serializer.fromJson<double?>(json['avgGapMps']),
      avgCadence: serializer.fromJson<int?>(json['avgCadence']),
      avgHeartRate: serializer.fromJson<int?>(json['avgHeartRate']),
      maxHeartRate: serializer.fromJson<int?>(json['maxHeartRate']),
      estimatedEnergyKj: serializer.fromJson<int?>(json['estimatedEnergyKj']),
      gravelPercentage: serializer.fromJson<double>(json['gravelPercentage']),
      asphaltPercentage: serializer.fromJson<double>(json['asphaltPercentage']),
      relativeEffort: serializer.fromJson<double>(json['relativeEffort']),
      gritScore: serializer.fromJson<double>(json['gritScore']),
      avgPowerW: serializer.fromJson<double?>(json['avgPowerW']),
      source: serializer.fromJson<String>(json['source']),
      primaryPhotoPath: serializer.fromJson<String?>(json['primaryPhotoPath']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'gearId': serializer.toJson<String?>(gearId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'sportType': serializer.toJson<String>(sportType),
      'status': serializer.toJson<String>(status),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'totalDistanceMeters': serializer.toJson<double>(totalDistanceMeters),
      'elapsedTimeSeconds': serializer.toJson<int>(elapsedTimeSeconds),
      'movingTimeSeconds': serializer.toJson<int>(movingTimeSeconds),
      'elevationGainMeters': serializer.toJson<double>(elevationGainMeters),
      'elevationLossMeters': serializer.toJson<double>(elevationLossMeters),
      'maxElevationMeters': serializer.toJson<double>(maxElevationMeters),
      'minElevationMeters': serializer.toJson<double>(minElevationMeters),
      'avgSpeedMps': serializer.toJson<double>(avgSpeedMps),
      'maxSpeedMps': serializer.toJson<double>(maxSpeedMps),
      'avgGapMps': serializer.toJson<double?>(avgGapMps),
      'avgCadence': serializer.toJson<int?>(avgCadence),
      'avgHeartRate': serializer.toJson<int?>(avgHeartRate),
      'maxHeartRate': serializer.toJson<int?>(maxHeartRate),
      'estimatedEnergyKj': serializer.toJson<int?>(estimatedEnergyKj),
      'gravelPercentage': serializer.toJson<double>(gravelPercentage),
      'asphaltPercentage': serializer.toJson<double>(asphaltPercentage),
      'relativeEffort': serializer.toJson<double>(relativeEffort),
      'gritScore': serializer.toJson<double>(gritScore),
      'avgPowerW': serializer.toJson<double?>(avgPowerW),
      'source': serializer.toJson<String>(source),
      'primaryPhotoPath': serializer.toJson<String?>(primaryPhotoPath),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Activity copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    Value<String?> gearId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    String? sportType,
    String? status,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    double? totalDistanceMeters,
    int? elapsedTimeSeconds,
    int? movingTimeSeconds,
    double? elevationGainMeters,
    double? elevationLossMeters,
    double? maxElevationMeters,
    double? minElevationMeters,
    double? avgSpeedMps,
    double? maxSpeedMps,
    Value<double?> avgGapMps = const Value.absent(),
    Value<int?> avgCadence = const Value.absent(),
    Value<int?> avgHeartRate = const Value.absent(),
    Value<int?> maxHeartRate = const Value.absent(),
    Value<int?> estimatedEnergyKj = const Value.absent(),
    double? gravelPercentage,
    double? asphaltPercentage,
    double? relativeEffort,
    double? gritScore,
    Value<double?> avgPowerW = const Value.absent(),
    String? source,
    Value<String?> primaryPhotoPath = const Value.absent(),
    bool? isFavorite,
    DateTime? updatedAt,
  }) => Activity(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    gearId: gearId.present ? gearId.value : this.gearId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    sportType: sportType ?? this.sportType,
    status: status ?? this.status,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
    elapsedTimeSeconds: elapsedTimeSeconds ?? this.elapsedTimeSeconds,
    movingTimeSeconds: movingTimeSeconds ?? this.movingTimeSeconds,
    elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
    elevationLossMeters: elevationLossMeters ?? this.elevationLossMeters,
    maxElevationMeters: maxElevationMeters ?? this.maxElevationMeters,
    minElevationMeters: minElevationMeters ?? this.minElevationMeters,
    avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
    maxSpeedMps: maxSpeedMps ?? this.maxSpeedMps,
    avgGapMps: avgGapMps.present ? avgGapMps.value : this.avgGapMps,
    avgCadence: avgCadence.present ? avgCadence.value : this.avgCadence,
    avgHeartRate: avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
    maxHeartRate: maxHeartRate.present ? maxHeartRate.value : this.maxHeartRate,
    estimatedEnergyKj: estimatedEnergyKj.present
        ? estimatedEnergyKj.value
        : this.estimatedEnergyKj,
    gravelPercentage: gravelPercentage ?? this.gravelPercentage,
    asphaltPercentage: asphaltPercentage ?? this.asphaltPercentage,
    relativeEffort: relativeEffort ?? this.relativeEffort,
    gritScore: gritScore ?? this.gritScore,
    avgPowerW: avgPowerW.present ? avgPowerW.value : this.avgPowerW,
    source: source ?? this.source,
    primaryPhotoPath: primaryPhotoPath.present
        ? primaryPhotoPath.value
        : this.primaryPhotoPath,
    isFavorite: isFavorite ?? this.isFavorite,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      gearId: data.gearId.present ? data.gearId.value : this.gearId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      sportType: data.sportType.present ? data.sportType.value : this.sportType,
      status: data.status.present ? data.status.value : this.status,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      totalDistanceMeters: data.totalDistanceMeters.present
          ? data.totalDistanceMeters.value
          : this.totalDistanceMeters,
      elapsedTimeSeconds: data.elapsedTimeSeconds.present
          ? data.elapsedTimeSeconds.value
          : this.elapsedTimeSeconds,
      movingTimeSeconds: data.movingTimeSeconds.present
          ? data.movingTimeSeconds.value
          : this.movingTimeSeconds,
      elevationGainMeters: data.elevationGainMeters.present
          ? data.elevationGainMeters.value
          : this.elevationGainMeters,
      elevationLossMeters: data.elevationLossMeters.present
          ? data.elevationLossMeters.value
          : this.elevationLossMeters,
      maxElevationMeters: data.maxElevationMeters.present
          ? data.maxElevationMeters.value
          : this.maxElevationMeters,
      minElevationMeters: data.minElevationMeters.present
          ? data.minElevationMeters.value
          : this.minElevationMeters,
      avgSpeedMps: data.avgSpeedMps.present
          ? data.avgSpeedMps.value
          : this.avgSpeedMps,
      maxSpeedMps: data.maxSpeedMps.present
          ? data.maxSpeedMps.value
          : this.maxSpeedMps,
      avgGapMps: data.avgGapMps.present ? data.avgGapMps.value : this.avgGapMps,
      avgCadence: data.avgCadence.present
          ? data.avgCadence.value
          : this.avgCadence,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      maxHeartRate: data.maxHeartRate.present
          ? data.maxHeartRate.value
          : this.maxHeartRate,
      estimatedEnergyKj: data.estimatedEnergyKj.present
          ? data.estimatedEnergyKj.value
          : this.estimatedEnergyKj,
      gravelPercentage: data.gravelPercentage.present
          ? data.gravelPercentage.value
          : this.gravelPercentage,
      asphaltPercentage: data.asphaltPercentage.present
          ? data.asphaltPercentage.value
          : this.asphaltPercentage,
      relativeEffort: data.relativeEffort.present
          ? data.relativeEffort.value
          : this.relativeEffort,
      gritScore: data.gritScore.present ? data.gritScore.value : this.gritScore,
      avgPowerW: data.avgPowerW.present ? data.avgPowerW.value : this.avgPowerW,
      source: data.source.present ? data.source.value : this.source,
      primaryPhotoPath: data.primaryPhotoPath.present
          ? data.primaryPhotoPath.value
          : this.primaryPhotoPath,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('gearId: $gearId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('sportType: $sportType, ')
          ..write('status: $status, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('totalDistanceMeters: $totalDistanceMeters, ')
          ..write('elapsedTimeSeconds: $elapsedTimeSeconds, ')
          ..write('movingTimeSeconds: $movingTimeSeconds, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('elevationLossMeters: $elevationLossMeters, ')
          ..write('maxElevationMeters: $maxElevationMeters, ')
          ..write('minElevationMeters: $minElevationMeters, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('maxSpeedMps: $maxSpeedMps, ')
          ..write('avgGapMps: $avgGapMps, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('estimatedEnergyKj: $estimatedEnergyKj, ')
          ..write('gravelPercentage: $gravelPercentage, ')
          ..write('asphaltPercentage: $asphaltPercentage, ')
          ..write('relativeEffort: $relativeEffort, ')
          ..write('gritScore: $gritScore, ')
          ..write('avgPowerW: $avgPowerW, ')
          ..write('source: $source, ')
          ..write('primaryPhotoPath: $primaryPhotoPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    gearId,
    title,
    description,
    sportType,
    status,
    startTime,
    endTime,
    totalDistanceMeters,
    elapsedTimeSeconds,
    movingTimeSeconds,
    elevationGainMeters,
    elevationLossMeters,
    maxElevationMeters,
    minElevationMeters,
    avgSpeedMps,
    maxSpeedMps,
    avgGapMps,
    avgCadence,
    avgHeartRate,
    maxHeartRate,
    estimatedEnergyKj,
    gravelPercentage,
    asphaltPercentage,
    relativeEffort,
    gritScore,
    avgPowerW,
    source,
    primaryPhotoPath,
    isFavorite,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.gearId == this.gearId &&
          other.title == this.title &&
          other.description == this.description &&
          other.sportType == this.sportType &&
          other.status == this.status &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.totalDistanceMeters == this.totalDistanceMeters &&
          other.elapsedTimeSeconds == this.elapsedTimeSeconds &&
          other.movingTimeSeconds == this.movingTimeSeconds &&
          other.elevationGainMeters == this.elevationGainMeters &&
          other.elevationLossMeters == this.elevationLossMeters &&
          other.maxElevationMeters == this.maxElevationMeters &&
          other.minElevationMeters == this.minElevationMeters &&
          other.avgSpeedMps == this.avgSpeedMps &&
          other.maxSpeedMps == this.maxSpeedMps &&
          other.avgGapMps == this.avgGapMps &&
          other.avgCadence == this.avgCadence &&
          other.avgHeartRate == this.avgHeartRate &&
          other.maxHeartRate == this.maxHeartRate &&
          other.estimatedEnergyKj == this.estimatedEnergyKj &&
          other.gravelPercentage == this.gravelPercentage &&
          other.asphaltPercentage == this.asphaltPercentage &&
          other.relativeEffort == this.relativeEffort &&
          other.gritScore == this.gritScore &&
          other.avgPowerW == this.avgPowerW &&
          other.source == this.source &&
          other.primaryPhotoPath == this.primaryPhotoPath &&
          other.isFavorite == this.isFavorite &&
          other.updatedAt == this.updatedAt);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String?> gearId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> sportType;
  final Value<String> status;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<double> totalDistanceMeters;
  final Value<int> elapsedTimeSeconds;
  final Value<int> movingTimeSeconds;
  final Value<double> elevationGainMeters;
  final Value<double> elevationLossMeters;
  final Value<double> maxElevationMeters;
  final Value<double> minElevationMeters;
  final Value<double> avgSpeedMps;
  final Value<double> maxSpeedMps;
  final Value<double?> avgGapMps;
  final Value<int?> avgCadence;
  final Value<int?> avgHeartRate;
  final Value<int?> maxHeartRate;
  final Value<int?> estimatedEnergyKj;
  final Value<double> gravelPercentage;
  final Value<double> asphaltPercentage;
  final Value<double> relativeEffort;
  final Value<double> gritScore;
  final Value<double?> avgPowerW;
  final Value<String> source;
  final Value<String?> primaryPhotoPath;
  final Value<bool> isFavorite;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.gearId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.sportType = const Value.absent(),
    this.status = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.totalDistanceMeters = const Value.absent(),
    this.elapsedTimeSeconds = const Value.absent(),
    this.movingTimeSeconds = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.elevationLossMeters = const Value.absent(),
    this.maxElevationMeters = const Value.absent(),
    this.minElevationMeters = const Value.absent(),
    this.avgSpeedMps = const Value.absent(),
    this.maxSpeedMps = const Value.absent(),
    this.avgGapMps = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.estimatedEnergyKj = const Value.absent(),
    this.gravelPercentage = const Value.absent(),
    this.asphaltPercentage = const Value.absent(),
    this.relativeEffort = const Value.absent(),
    this.gritScore = const Value.absent(),
    this.avgPowerW = const Value.absent(),
    this.source = const Value.absent(),
    this.primaryPhotoPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    this.gearId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required String sportType,
    required String status,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.totalDistanceMeters = const Value.absent(),
    this.elapsedTimeSeconds = const Value.absent(),
    this.movingTimeSeconds = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.elevationLossMeters = const Value.absent(),
    this.maxElevationMeters = const Value.absent(),
    this.minElevationMeters = const Value.absent(),
    this.avgSpeedMps = const Value.absent(),
    this.maxSpeedMps = const Value.absent(),
    this.avgGapMps = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.estimatedEnergyKj = const Value.absent(),
    this.gravelPercentage = const Value.absent(),
    this.asphaltPercentage = const Value.absent(),
    this.relativeEffort = const Value.absent(),
    this.gritScore = const Value.absent(),
    this.avgPowerW = const Value.absent(),
    this.source = const Value.absent(),
    this.primaryPhotoPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       sportType = Value(sportType),
       status = Value(status),
       startTime = Value(startTime),
       updatedAt = Value(updatedAt);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? gearId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? sportType,
    Expression<String>? status,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<double>? totalDistanceMeters,
    Expression<int>? elapsedTimeSeconds,
    Expression<int>? movingTimeSeconds,
    Expression<double>? elevationGainMeters,
    Expression<double>? elevationLossMeters,
    Expression<double>? maxElevationMeters,
    Expression<double>? minElevationMeters,
    Expression<double>? avgSpeedMps,
    Expression<double>? maxSpeedMps,
    Expression<double>? avgGapMps,
    Expression<int>? avgCadence,
    Expression<int>? avgHeartRate,
    Expression<int>? maxHeartRate,
    Expression<int>? estimatedEnergyKj,
    Expression<double>? gravelPercentage,
    Expression<double>? asphaltPercentage,
    Expression<double>? relativeEffort,
    Expression<double>? gritScore,
    Expression<double>? avgPowerW,
    Expression<String>? source,
    Expression<String>? primaryPhotoPath,
    Expression<bool>? isFavorite,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (gearId != null) 'gear_id': gearId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (sportType != null) 'sport_type': sportType,
      if (status != null) 'status': status,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (totalDistanceMeters != null)
        'total_distance_meters': totalDistanceMeters,
      if (elapsedTimeSeconds != null)
        'elapsed_time_seconds': elapsedTimeSeconds,
      if (movingTimeSeconds != null) 'moving_time_seconds': movingTimeSeconds,
      if (elevationGainMeters != null)
        'elevation_gain_meters': elevationGainMeters,
      if (elevationLossMeters != null)
        'elevation_loss_meters': elevationLossMeters,
      if (maxElevationMeters != null)
        'max_elevation_meters': maxElevationMeters,
      if (minElevationMeters != null)
        'min_elevation_meters': minElevationMeters,
      if (avgSpeedMps != null) 'avg_speed_mps': avgSpeedMps,
      if (maxSpeedMps != null) 'max_speed_mps': maxSpeedMps,
      if (avgGapMps != null) 'avg_gap_mps': avgGapMps,
      if (avgCadence != null) 'avg_cadence': avgCadence,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
      if (estimatedEnergyKj != null) 'estimated_energy_kj': estimatedEnergyKj,
      if (gravelPercentage != null) 'gravel_percentage': gravelPercentage,
      if (asphaltPercentage != null) 'asphalt_percentage': asphaltPercentage,
      if (relativeEffort != null) 'relative_effort': relativeEffort,
      if (gritScore != null) 'grit_score': gritScore,
      if (avgPowerW != null) 'avg_power_w': avgPowerW,
      if (source != null) 'source': source,
      if (primaryPhotoPath != null) 'primary_photo_path': primaryPhotoPath,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String?>? gearId,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? sportType,
    Value<String>? status,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<double>? totalDistanceMeters,
    Value<int>? elapsedTimeSeconds,
    Value<int>? movingTimeSeconds,
    Value<double>? elevationGainMeters,
    Value<double>? elevationLossMeters,
    Value<double>? maxElevationMeters,
    Value<double>? minElevationMeters,
    Value<double>? avgSpeedMps,
    Value<double>? maxSpeedMps,
    Value<double?>? avgGapMps,
    Value<int?>? avgCadence,
    Value<int?>? avgHeartRate,
    Value<int?>? maxHeartRate,
    Value<int?>? estimatedEnergyKj,
    Value<double>? gravelPercentage,
    Value<double>? asphaltPercentage,
    Value<double>? relativeEffort,
    Value<double>? gritScore,
    Value<double?>? avgPowerW,
    Value<String>? source,
    Value<String?>? primaryPhotoPath,
    Value<bool>? isFavorite,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gearId: gearId ?? this.gearId,
      title: title ?? this.title,
      description: description ?? this.description,
      sportType: sportType ?? this.sportType,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      elapsedTimeSeconds: elapsedTimeSeconds ?? this.elapsedTimeSeconds,
      movingTimeSeconds: movingTimeSeconds ?? this.movingTimeSeconds,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      elevationLossMeters: elevationLossMeters ?? this.elevationLossMeters,
      maxElevationMeters: maxElevationMeters ?? this.maxElevationMeters,
      minElevationMeters: minElevationMeters ?? this.minElevationMeters,
      avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
      maxSpeedMps: maxSpeedMps ?? this.maxSpeedMps,
      avgGapMps: avgGapMps ?? this.avgGapMps,
      avgCadence: avgCadence ?? this.avgCadence,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      estimatedEnergyKj: estimatedEnergyKj ?? this.estimatedEnergyKj,
      gravelPercentage: gravelPercentage ?? this.gravelPercentage,
      asphaltPercentage: asphaltPercentage ?? this.asphaltPercentage,
      relativeEffort: relativeEffort ?? this.relativeEffort,
      gritScore: gritScore ?? this.gritScore,
      avgPowerW: avgPowerW ?? this.avgPowerW,
      source: source ?? this.source,
      primaryPhotoPath: primaryPhotoPath ?? this.primaryPhotoPath,
      isFavorite: isFavorite ?? this.isFavorite,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (gearId.present) {
      map['gear_id'] = Variable<String>(gearId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sportType.present) {
      map['sport_type'] = Variable<String>(sportType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (totalDistanceMeters.present) {
      map['total_distance_meters'] = Variable<double>(
        totalDistanceMeters.value,
      );
    }
    if (elapsedTimeSeconds.present) {
      map['elapsed_time_seconds'] = Variable<int>(elapsedTimeSeconds.value);
    }
    if (movingTimeSeconds.present) {
      map['moving_time_seconds'] = Variable<int>(movingTimeSeconds.value);
    }
    if (elevationGainMeters.present) {
      map['elevation_gain_meters'] = Variable<double>(
        elevationGainMeters.value,
      );
    }
    if (elevationLossMeters.present) {
      map['elevation_loss_meters'] = Variable<double>(
        elevationLossMeters.value,
      );
    }
    if (maxElevationMeters.present) {
      map['max_elevation_meters'] = Variable<double>(maxElevationMeters.value);
    }
    if (minElevationMeters.present) {
      map['min_elevation_meters'] = Variable<double>(minElevationMeters.value);
    }
    if (avgSpeedMps.present) {
      map['avg_speed_mps'] = Variable<double>(avgSpeedMps.value);
    }
    if (maxSpeedMps.present) {
      map['max_speed_mps'] = Variable<double>(maxSpeedMps.value);
    }
    if (avgGapMps.present) {
      map['avg_gap_mps'] = Variable<double>(avgGapMps.value);
    }
    if (avgCadence.present) {
      map['avg_cadence'] = Variable<int>(avgCadence.value);
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (maxHeartRate.present) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate.value);
    }
    if (estimatedEnergyKj.present) {
      map['estimated_energy_kj'] = Variable<int>(estimatedEnergyKj.value);
    }
    if (gravelPercentage.present) {
      map['gravel_percentage'] = Variable<double>(gravelPercentage.value);
    }
    if (asphaltPercentage.present) {
      map['asphalt_percentage'] = Variable<double>(asphaltPercentage.value);
    }
    if (relativeEffort.present) {
      map['relative_effort'] = Variable<double>(relativeEffort.value);
    }
    if (gritScore.present) {
      map['grit_score'] = Variable<double>(gritScore.value);
    }
    if (avgPowerW.present) {
      map['avg_power_w'] = Variable<double>(avgPowerW.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (primaryPhotoPath.present) {
      map['primary_photo_path'] = Variable<String>(primaryPhotoPath.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('gearId: $gearId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('sportType: $sportType, ')
          ..write('status: $status, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('totalDistanceMeters: $totalDistanceMeters, ')
          ..write('elapsedTimeSeconds: $elapsedTimeSeconds, ')
          ..write('movingTimeSeconds: $movingTimeSeconds, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('elevationLossMeters: $elevationLossMeters, ')
          ..write('maxElevationMeters: $maxElevationMeters, ')
          ..write('minElevationMeters: $minElevationMeters, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('maxSpeedMps: $maxSpeedMps, ')
          ..write('avgGapMps: $avgGapMps, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('estimatedEnergyKj: $estimatedEnergyKj, ')
          ..write('gravelPercentage: $gravelPercentage, ')
          ..write('asphaltPercentage: $asphaltPercentage, ')
          ..write('relativeEffort: $relativeEffort, ')
          ..write('gritScore: $gritScore, ')
          ..write('avgPowerW: $avgPowerW, ')
          ..write('source: $source, ')
          ..write('primaryPhotoPath: $primaryPhotoPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackPointsTable extends TrackPoints
    with TableInfo<$TrackPointsTable, TrackPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceIdxMeta = const VerificationMeta(
    'sequenceIdx',
  );
  @override
  late final GeneratedColumn<int> sequenceIdx = GeneratedColumn<int>(
    'sequence_idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMetersMeta = const VerificationMeta(
    'altitudeMeters',
  );
  @override
  late final GeneratedColumn<double> altitudeMeters = GeneratedColumn<double>(
    'altitude_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMetersMeta = const VerificationMeta(
    'accuracyMeters',
  );
  @override
  late final GeneratedColumn<double> accuracyMeters = GeneratedColumn<double>(
    'accuracy_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedMpsMeta = const VerificationMeta(
    'speedMps',
  );
  @override
  late final GeneratedColumn<double> speedMps = GeneratedColumn<double>(
    'speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bearingDegreesMeta = const VerificationMeta(
    'bearingDegrees',
  );
  @override
  late final GeneratedColumn<double> bearingDegrees = GeneratedColumn<double>(
    'bearing_degrees',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _gradePctMeta = const VerificationMeta(
    'gradePct',
  );
  @override
  late final GeneratedColumn<double> gradePct = GeneratedColumn<double>(
    'grade_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _surfaceTypeMeta = const VerificationMeta(
    'surfaceType',
  );
  @override
  late final GeneratedColumn<String> surfaceType = GeneratedColumn<String>(
    'surface_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _vibrationRawMeta = const VerificationMeta(
    'vibrationRaw',
  );
  @override
  late final GeneratedColumn<double> vibrationRaw = GeneratedColumn<double>(
    'vibration_raw',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _heartRateMeta = const VerificationMeta(
    'heartRate',
  );
  @override
  late final GeneratedColumn<int> heartRate = GeneratedColumn<int>(
    'heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cadenceMeta = const VerificationMeta(
    'cadence',
  );
  @override
  late final GeneratedColumn<int> cadence = GeneratedColumn<int>(
    'cadence',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPausedMeta = const VerificationMeta(
    'isPaused',
  );
  @override
  late final GeneratedColumn<bool> isPaused = GeneratedColumn<bool>(
    'is_paused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    sequenceIdx,
    timestamp,
    latitude,
    longitude,
    altitudeMeters,
    accuracyMeters,
    speedMps,
    bearingDegrees,
    gradePct,
    surfaceType,
    vibrationRaw,
    heartRate,
    cadence,
    isPaused,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('sequence_idx')) {
      context.handle(
        _sequenceIdxMeta,
        sequenceIdx.isAcceptableOrUnknown(
          data['sequence_idx']!,
          _sequenceIdxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceIdxMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude_meters')) {
      context.handle(
        _altitudeMetersMeta,
        altitudeMeters.isAcceptableOrUnknown(
          data['altitude_meters']!,
          _altitudeMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_altitudeMetersMeta);
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
        _accuracyMetersMeta,
        accuracyMeters.isAcceptableOrUnknown(
          data['accuracy_meters']!,
          _accuracyMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accuracyMetersMeta);
    }
    if (data.containsKey('speed_mps')) {
      context.handle(
        _speedMpsMeta,
        speedMps.isAcceptableOrUnknown(data['speed_mps']!, _speedMpsMeta),
      );
    } else if (isInserting) {
      context.missing(_speedMpsMeta);
    }
    if (data.containsKey('bearing_degrees')) {
      context.handle(
        _bearingDegreesMeta,
        bearingDegrees.isAcceptableOrUnknown(
          data['bearing_degrees']!,
          _bearingDegreesMeta,
        ),
      );
    }
    if (data.containsKey('grade_pct')) {
      context.handle(
        _gradePctMeta,
        gradePct.isAcceptableOrUnknown(data['grade_pct']!, _gradePctMeta),
      );
    }
    if (data.containsKey('surface_type')) {
      context.handle(
        _surfaceTypeMeta,
        surfaceType.isAcceptableOrUnknown(
          data['surface_type']!,
          _surfaceTypeMeta,
        ),
      );
    }
    if (data.containsKey('vibration_raw')) {
      context.handle(
        _vibrationRawMeta,
        vibrationRaw.isAcceptableOrUnknown(
          data['vibration_raw']!,
          _vibrationRawMeta,
        ),
      );
    }
    if (data.containsKey('heart_rate')) {
      context.handle(
        _heartRateMeta,
        heartRate.isAcceptableOrUnknown(data['heart_rate']!, _heartRateMeta),
      );
    }
    if (data.containsKey('cadence')) {
      context.handle(
        _cadenceMeta,
        cadence.isAcceptableOrUnknown(data['cadence']!, _cadenceMeta),
      );
    }
    if (data.containsKey('is_paused')) {
      context.handle(
        _isPausedMeta,
        isPaused.isAcceptableOrUnknown(data['is_paused']!, _isPausedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      sequenceIdx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_idx'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitudeMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_meters'],
      )!,
      accuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_meters'],
      )!,
      speedMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_mps'],
      )!,
      bearingDegrees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bearing_degrees'],
      )!,
      gradePct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grade_pct'],
      )!,
      surfaceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surface_type'],
      )!,
      vibrationRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vibration_raw'],
      )!,
      heartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate'],
      ),
      cadence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cadence'],
      ),
      isPaused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paused'],
      )!,
    );
  }

  @override
  $TrackPointsTable createAlias(String alias) {
    return $TrackPointsTable(attachedDatabase, alias);
  }
}

class TrackPoint extends DataClass implements Insertable<TrackPoint> {
  final int id;
  final String activityId;
  final int sequenceIdx;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double altitudeMeters;
  final double accuracyMeters;
  final double speedMps;
  final double bearingDegrees;
  final double gradePct;
  final String surfaceType;
  final double vibrationRaw;
  final int? heartRate;
  final int? cadence;
  final bool isPaused;
  const TrackPoint({
    required this.id,
    required this.activityId,
    required this.sequenceIdx,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.altitudeMeters,
    required this.accuracyMeters,
    required this.speedMps,
    required this.bearingDegrees,
    required this.gradePct,
    required this.surfaceType,
    required this.vibrationRaw,
    this.heartRate,
    this.cadence,
    required this.isPaused,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['sequence_idx'] = Variable<int>(sequenceIdx);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['altitude_meters'] = Variable<double>(altitudeMeters);
    map['accuracy_meters'] = Variable<double>(accuracyMeters);
    map['speed_mps'] = Variable<double>(speedMps);
    map['bearing_degrees'] = Variable<double>(bearingDegrees);
    map['grade_pct'] = Variable<double>(gradePct);
    map['surface_type'] = Variable<String>(surfaceType);
    map['vibration_raw'] = Variable<double>(vibrationRaw);
    if (!nullToAbsent || heartRate != null) {
      map['heart_rate'] = Variable<int>(heartRate);
    }
    if (!nullToAbsent || cadence != null) {
      map['cadence'] = Variable<int>(cadence);
    }
    map['is_paused'] = Variable<bool>(isPaused);
    return map;
  }

  TrackPointsCompanion toCompanion(bool nullToAbsent) {
    return TrackPointsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      sequenceIdx: Value(sequenceIdx),
      timestamp: Value(timestamp),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitudeMeters: Value(altitudeMeters),
      accuracyMeters: Value(accuracyMeters),
      speedMps: Value(speedMps),
      bearingDegrees: Value(bearingDegrees),
      gradePct: Value(gradePct),
      surfaceType: Value(surfaceType),
      vibrationRaw: Value(vibrationRaw),
      heartRate: heartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRate),
      cadence: cadence == null && nullToAbsent
          ? const Value.absent()
          : Value(cadence),
      isPaused: Value(isPaused),
    );
  }

  factory TrackPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackPoint(
      id: serializer.fromJson<int>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      sequenceIdx: serializer.fromJson<int>(json['sequenceIdx']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitudeMeters: serializer.fromJson<double>(json['altitudeMeters']),
      accuracyMeters: serializer.fromJson<double>(json['accuracyMeters']),
      speedMps: serializer.fromJson<double>(json['speedMps']),
      bearingDegrees: serializer.fromJson<double>(json['bearingDegrees']),
      gradePct: serializer.fromJson<double>(json['gradePct']),
      surfaceType: serializer.fromJson<String>(json['surfaceType']),
      vibrationRaw: serializer.fromJson<double>(json['vibrationRaw']),
      heartRate: serializer.fromJson<int?>(json['heartRate']),
      cadence: serializer.fromJson<int?>(json['cadence']),
      isPaused: serializer.fromJson<bool>(json['isPaused']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'activityId': serializer.toJson<String>(activityId),
      'sequenceIdx': serializer.toJson<int>(sequenceIdx),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitudeMeters': serializer.toJson<double>(altitudeMeters),
      'accuracyMeters': serializer.toJson<double>(accuracyMeters),
      'speedMps': serializer.toJson<double>(speedMps),
      'bearingDegrees': serializer.toJson<double>(bearingDegrees),
      'gradePct': serializer.toJson<double>(gradePct),
      'surfaceType': serializer.toJson<String>(surfaceType),
      'vibrationRaw': serializer.toJson<double>(vibrationRaw),
      'heartRate': serializer.toJson<int?>(heartRate),
      'cadence': serializer.toJson<int?>(cadence),
      'isPaused': serializer.toJson<bool>(isPaused),
    };
  }

  TrackPoint copyWith({
    int? id,
    String? activityId,
    int? sequenceIdx,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? altitudeMeters,
    double? accuracyMeters,
    double? speedMps,
    double? bearingDegrees,
    double? gradePct,
    String? surfaceType,
    double? vibrationRaw,
    Value<int?> heartRate = const Value.absent(),
    Value<int?> cadence = const Value.absent(),
    bool? isPaused,
  }) => TrackPoint(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    sequenceIdx: sequenceIdx ?? this.sequenceIdx,
    timestamp: timestamp ?? this.timestamp,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitudeMeters: altitudeMeters ?? this.altitudeMeters,
    accuracyMeters: accuracyMeters ?? this.accuracyMeters,
    speedMps: speedMps ?? this.speedMps,
    bearingDegrees: bearingDegrees ?? this.bearingDegrees,
    gradePct: gradePct ?? this.gradePct,
    surfaceType: surfaceType ?? this.surfaceType,
    vibrationRaw: vibrationRaw ?? this.vibrationRaw,
    heartRate: heartRate.present ? heartRate.value : this.heartRate,
    cadence: cadence.present ? cadence.value : this.cadence,
    isPaused: isPaused ?? this.isPaused,
  );
  TrackPoint copyWithCompanion(TrackPointsCompanion data) {
    return TrackPoint(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      sequenceIdx: data.sequenceIdx.present
          ? data.sequenceIdx.value
          : this.sequenceIdx,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitudeMeters: data.altitudeMeters.present
          ? data.altitudeMeters.value
          : this.altitudeMeters,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
      speedMps: data.speedMps.present ? data.speedMps.value : this.speedMps,
      bearingDegrees: data.bearingDegrees.present
          ? data.bearingDegrees.value
          : this.bearingDegrees,
      gradePct: data.gradePct.present ? data.gradePct.value : this.gradePct,
      surfaceType: data.surfaceType.present
          ? data.surfaceType.value
          : this.surfaceType,
      vibrationRaw: data.vibrationRaw.present
          ? data.vibrationRaw.value
          : this.vibrationRaw,
      heartRate: data.heartRate.present ? data.heartRate.value : this.heartRate,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      isPaused: data.isPaused.present ? data.isPaused.value : this.isPaused,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackPoint(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('sequenceIdx: $sequenceIdx, ')
          ..write('timestamp: $timestamp, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitudeMeters: $altitudeMeters, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('speedMps: $speedMps, ')
          ..write('bearingDegrees: $bearingDegrees, ')
          ..write('gradePct: $gradePct, ')
          ..write('surfaceType: $surfaceType, ')
          ..write('vibrationRaw: $vibrationRaw, ')
          ..write('heartRate: $heartRate, ')
          ..write('cadence: $cadence, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityId,
    sequenceIdx,
    timestamp,
    latitude,
    longitude,
    altitudeMeters,
    accuracyMeters,
    speedMps,
    bearingDegrees,
    gradePct,
    surfaceType,
    vibrationRaw,
    heartRate,
    cadence,
    isPaused,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackPoint &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.sequenceIdx == this.sequenceIdx &&
          other.timestamp == this.timestamp &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitudeMeters == this.altitudeMeters &&
          other.accuracyMeters == this.accuracyMeters &&
          other.speedMps == this.speedMps &&
          other.bearingDegrees == this.bearingDegrees &&
          other.gradePct == this.gradePct &&
          other.surfaceType == this.surfaceType &&
          other.vibrationRaw == this.vibrationRaw &&
          other.heartRate == this.heartRate &&
          other.cadence == this.cadence &&
          other.isPaused == this.isPaused);
}

class TrackPointsCompanion extends UpdateCompanion<TrackPoint> {
  final Value<int> id;
  final Value<String> activityId;
  final Value<int> sequenceIdx;
  final Value<DateTime> timestamp;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> altitudeMeters;
  final Value<double> accuracyMeters;
  final Value<double> speedMps;
  final Value<double> bearingDegrees;
  final Value<double> gradePct;
  final Value<String> surfaceType;
  final Value<double> vibrationRaw;
  final Value<int?> heartRate;
  final Value<int?> cadence;
  final Value<bool> isPaused;
  const TrackPointsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.sequenceIdx = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitudeMeters = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.bearingDegrees = const Value.absent(),
    this.gradePct = const Value.absent(),
    this.surfaceType = const Value.absent(),
    this.vibrationRaw = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.cadence = const Value.absent(),
    this.isPaused = const Value.absent(),
  });
  TrackPointsCompanion.insert({
    this.id = const Value.absent(),
    required String activityId,
    required int sequenceIdx,
    required DateTime timestamp,
    required double latitude,
    required double longitude,
    required double altitudeMeters,
    required double accuracyMeters,
    required double speedMps,
    this.bearingDegrees = const Value.absent(),
    this.gradePct = const Value.absent(),
    this.surfaceType = const Value.absent(),
    this.vibrationRaw = const Value.absent(),
    this.heartRate = const Value.absent(),
    this.cadence = const Value.absent(),
    this.isPaused = const Value.absent(),
  }) : activityId = Value(activityId),
       sequenceIdx = Value(sequenceIdx),
       timestamp = Value(timestamp),
       latitude = Value(latitude),
       longitude = Value(longitude),
       altitudeMeters = Value(altitudeMeters),
       accuracyMeters = Value(accuracyMeters),
       speedMps = Value(speedMps);
  static Insertable<TrackPoint> custom({
    Expression<int>? id,
    Expression<String>? activityId,
    Expression<int>? sequenceIdx,
    Expression<DateTime>? timestamp,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitudeMeters,
    Expression<double>? accuracyMeters,
    Expression<double>? speedMps,
    Expression<double>? bearingDegrees,
    Expression<double>? gradePct,
    Expression<String>? surfaceType,
    Expression<double>? vibrationRaw,
    Expression<int>? heartRate,
    Expression<int>? cadence,
    Expression<bool>? isPaused,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (sequenceIdx != null) 'sequence_idx': sequenceIdx,
      if (timestamp != null) 'timestamp': timestamp,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitudeMeters != null) 'altitude_meters': altitudeMeters,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      if (speedMps != null) 'speed_mps': speedMps,
      if (bearingDegrees != null) 'bearing_degrees': bearingDegrees,
      if (gradePct != null) 'grade_pct': gradePct,
      if (surfaceType != null) 'surface_type': surfaceType,
      if (vibrationRaw != null) 'vibration_raw': vibrationRaw,
      if (heartRate != null) 'heart_rate': heartRate,
      if (cadence != null) 'cadence': cadence,
      if (isPaused != null) 'is_paused': isPaused,
    });
  }

  TrackPointsCompanion copyWith({
    Value<int>? id,
    Value<String>? activityId,
    Value<int>? sequenceIdx,
    Value<DateTime>? timestamp,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? altitudeMeters,
    Value<double>? accuracyMeters,
    Value<double>? speedMps,
    Value<double>? bearingDegrees,
    Value<double>? gradePct,
    Value<String>? surfaceType,
    Value<double>? vibrationRaw,
    Value<int?>? heartRate,
    Value<int?>? cadence,
    Value<bool>? isPaused,
  }) {
    return TrackPointsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      sequenceIdx: sequenceIdx ?? this.sequenceIdx,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      speedMps: speedMps ?? this.speedMps,
      bearingDegrees: bearingDegrees ?? this.bearingDegrees,
      gradePct: gradePct ?? this.gradePct,
      surfaceType: surfaceType ?? this.surfaceType,
      vibrationRaw: vibrationRaw ?? this.vibrationRaw,
      heartRate: heartRate ?? this.heartRate,
      cadence: cadence ?? this.cadence,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (sequenceIdx.present) {
      map['sequence_idx'] = Variable<int>(sequenceIdx.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitudeMeters.present) {
      map['altitude_meters'] = Variable<double>(altitudeMeters.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters.value);
    }
    if (speedMps.present) {
      map['speed_mps'] = Variable<double>(speedMps.value);
    }
    if (bearingDegrees.present) {
      map['bearing_degrees'] = Variable<double>(bearingDegrees.value);
    }
    if (gradePct.present) {
      map['grade_pct'] = Variable<double>(gradePct.value);
    }
    if (surfaceType.present) {
      map['surface_type'] = Variable<String>(surfaceType.value);
    }
    if (vibrationRaw.present) {
      map['vibration_raw'] = Variable<double>(vibrationRaw.value);
    }
    if (heartRate.present) {
      map['heart_rate'] = Variable<int>(heartRate.value);
    }
    if (cadence.present) {
      map['cadence'] = Variable<int>(cadence.value);
    }
    if (isPaused.present) {
      map['is_paused'] = Variable<bool>(isPaused.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('sequenceIdx: $sequenceIdx, ')
          ..write('timestamp: $timestamp, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitudeMeters: $altitudeMeters, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('speedMps: $speedMps, ')
          ..write('bearingDegrees: $bearingDegrees, ')
          ..write('gradePct: $gradePct, ')
          ..write('surfaceType: $surfaceType, ')
          ..write('vibrationRaw: $vibrationRaw, ')
          ..write('heartRate: $heartRate, ')
          ..write('cadence: $cadence, ')
          ..write('isPaused: $isPaused')
          ..write(')'))
        .toString();
  }
}

class $WaypointPhotosTable extends WaypointPhotos
    with TableInfo<$WaypointPhotosTable, WaypointPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaypointPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMetersMeta = const VerificationMeta(
    'altitudeMeters',
  );
  @override
  late final GeneratedColumn<double> altitudeMeters = GeneratedColumn<double>(
    'altitude_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceFromStartMetersMeta =
      const VerificationMeta('distanceFromStartMeters');
  @override
  late final GeneratedColumn<double> distanceFromStartMeters =
      GeneratedColumn<double>(
        'distance_from_start_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    filePath,
    latitude,
    longitude,
    altitudeMeters,
    distanceFromStartMeters,
    takenAt,
    caption,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'waypoint_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaypointPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude_meters')) {
      context.handle(
        _altitudeMetersMeta,
        altitudeMeters.isAcceptableOrUnknown(
          data['altitude_meters']!,
          _altitudeMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_altitudeMetersMeta);
    }
    if (data.containsKey('distance_from_start_meters')) {
      context.handle(
        _distanceFromStartMetersMeta,
        distanceFromStartMeters.isAcceptableOrUnknown(
          data['distance_from_start_meters']!,
          _distanceFromStartMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceFromStartMetersMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaypointPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaypointPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitudeMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_meters'],
      )!,
      distanceFromStartMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_from_start_meters'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
    );
  }

  @override
  $WaypointPhotosTable createAlias(String alias) {
    return $WaypointPhotosTable(attachedDatabase, alias);
  }
}

class WaypointPhoto extends DataClass implements Insertable<WaypointPhoto> {
  final String id;
  final String activityId;
  final String filePath;
  final double latitude;
  final double longitude;
  final double altitudeMeters;
  final double distanceFromStartMeters;
  final DateTime takenAt;
  final String? caption;
  const WaypointPhoto({
    required this.id,
    required this.activityId,
    required this.filePath,
    required this.latitude,
    required this.longitude,
    required this.altitudeMeters,
    required this.distanceFromStartMeters,
    required this.takenAt,
    this.caption,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['file_path'] = Variable<String>(filePath);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['altitude_meters'] = Variable<double>(altitudeMeters);
    map['distance_from_start_meters'] = Variable<double>(
      distanceFromStartMeters,
    );
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    return map;
  }

  WaypointPhotosCompanion toCompanion(bool nullToAbsent) {
    return WaypointPhotosCompanion(
      id: Value(id),
      activityId: Value(activityId),
      filePath: Value(filePath),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitudeMeters: Value(altitudeMeters),
      distanceFromStartMeters: Value(distanceFromStartMeters),
      takenAt: Value(takenAt),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
    );
  }

  factory WaypointPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaypointPhoto(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitudeMeters: serializer.fromJson<double>(json['altitudeMeters']),
      distanceFromStartMeters: serializer.fromJson<double>(
        json['distanceFromStartMeters'],
      ),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      caption: serializer.fromJson<String?>(json['caption']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'filePath': serializer.toJson<String>(filePath),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitudeMeters': serializer.toJson<double>(altitudeMeters),
      'distanceFromStartMeters': serializer.toJson<double>(
        distanceFromStartMeters,
      ),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'caption': serializer.toJson<String?>(caption),
    };
  }

  WaypointPhoto copyWith({
    String? id,
    String? activityId,
    String? filePath,
    double? latitude,
    double? longitude,
    double? altitudeMeters,
    double? distanceFromStartMeters,
    DateTime? takenAt,
    Value<String?> caption = const Value.absent(),
  }) => WaypointPhoto(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    filePath: filePath ?? this.filePath,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitudeMeters: altitudeMeters ?? this.altitudeMeters,
    distanceFromStartMeters:
        distanceFromStartMeters ?? this.distanceFromStartMeters,
    takenAt: takenAt ?? this.takenAt,
    caption: caption.present ? caption.value : this.caption,
  );
  WaypointPhoto copyWithCompanion(WaypointPhotosCompanion data) {
    return WaypointPhoto(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitudeMeters: data.altitudeMeters.present
          ? data.altitudeMeters.value
          : this.altitudeMeters,
      distanceFromStartMeters: data.distanceFromStartMeters.present
          ? data.distanceFromStartMeters.value
          : this.distanceFromStartMeters,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      caption: data.caption.present ? data.caption.value : this.caption,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaypointPhoto(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('filePath: $filePath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitudeMeters: $altitudeMeters, ')
          ..write('distanceFromStartMeters: $distanceFromStartMeters, ')
          ..write('takenAt: $takenAt, ')
          ..write('caption: $caption')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityId,
    filePath,
    latitude,
    longitude,
    altitudeMeters,
    distanceFromStartMeters,
    takenAt,
    caption,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaypointPhoto &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.filePath == this.filePath &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitudeMeters == this.altitudeMeters &&
          other.distanceFromStartMeters == this.distanceFromStartMeters &&
          other.takenAt == this.takenAt &&
          other.caption == this.caption);
}

class WaypointPhotosCompanion extends UpdateCompanion<WaypointPhoto> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<String> filePath;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> altitudeMeters;
  final Value<double> distanceFromStartMeters;
  final Value<DateTime> takenAt;
  final Value<String?> caption;
  final Value<int> rowid;
  const WaypointPhotosCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitudeMeters = const Value.absent(),
    this.distanceFromStartMeters = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.caption = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaypointPhotosCompanion.insert({
    required String id,
    required String activityId,
    required String filePath,
    required double latitude,
    required double longitude,
    required double altitudeMeters,
    required double distanceFromStartMeters,
    required DateTime takenAt,
    this.caption = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityId = Value(activityId),
       filePath = Value(filePath),
       latitude = Value(latitude),
       longitude = Value(longitude),
       altitudeMeters = Value(altitudeMeters),
       distanceFromStartMeters = Value(distanceFromStartMeters),
       takenAt = Value(takenAt);
  static Insertable<WaypointPhoto> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<String>? filePath,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitudeMeters,
    Expression<double>? distanceFromStartMeters,
    Expression<DateTime>? takenAt,
    Expression<String>? caption,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (filePath != null) 'file_path': filePath,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitudeMeters != null) 'altitude_meters': altitudeMeters,
      if (distanceFromStartMeters != null)
        'distance_from_start_meters': distanceFromStartMeters,
      if (takenAt != null) 'taken_at': takenAt,
      if (caption != null) 'caption': caption,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaypointPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? activityId,
    Value<String>? filePath,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? altitudeMeters,
    Value<double>? distanceFromStartMeters,
    Value<DateTime>? takenAt,
    Value<String?>? caption,
    Value<int>? rowid,
  }) {
    return WaypointPhotosCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      filePath: filePath ?? this.filePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      distanceFromStartMeters:
          distanceFromStartMeters ?? this.distanceFromStartMeters,
      takenAt: takenAt ?? this.takenAt,
      caption: caption ?? this.caption,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitudeMeters.present) {
      map['altitude_meters'] = Variable<double>(altitudeMeters.value);
    }
    if (distanceFromStartMeters.present) {
      map['distance_from_start_meters'] = Variable<double>(
        distanceFromStartMeters.value,
      );
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaypointPhotosCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('filePath: $filePath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitudeMeters: $altitudeMeters, ')
          ..write('distanceFromStartMeters: $distanceFromStartMeters, ')
          ..write('takenAt: $takenAt, ')
          ..write('caption: $caption, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GearsTable extends Gears with TableInfo<$GearsTable, Gear> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GearsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gearTypeMeta = const VerificationMeta(
    'gearType',
  );
  @override
  late final GeneratedColumn<String> gearType = GeneratedColumn<String>(
    'gear_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandModelMeta = const VerificationMeta(
    'brandModel',
  );
  @override
  late final GeneratedColumn<String> brandModel = GeneratedColumn<String>(
    'brand_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDistanceMetersMeta =
      const VerificationMeta('totalDistanceMeters');
  @override
  late final GeneratedColumn<double> totalDistanceMeters =
      GeneratedColumn<double>(
        'total_distance_meters',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isRetiredMeta = const VerificationMeta(
    'isRetired',
  );
  @override
  late final GeneratedColumn<bool> isRetired = GeneratedColumn<bool>(
    'is_retired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_retired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    gearType,
    brandModel,
    totalDistanceMeters,
    isDefault,
    isRetired,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gears';
  @override
  VerificationContext validateIntegrity(
    Insertable<Gear> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('gear_type')) {
      context.handle(
        _gearTypeMeta,
        gearType.isAcceptableOrUnknown(data['gear_type']!, _gearTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_gearTypeMeta);
    }
    if (data.containsKey('brand_model')) {
      context.handle(
        _brandModelMeta,
        brandModel.isAcceptableOrUnknown(data['brand_model']!, _brandModelMeta),
      );
    }
    if (data.containsKey('total_distance_meters')) {
      context.handle(
        _totalDistanceMetersMeta,
        totalDistanceMeters.isAcceptableOrUnknown(
          data['total_distance_meters']!,
          _totalDistanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_retired')) {
      context.handle(
        _isRetiredMeta,
        isRetired.isAcceptableOrUnknown(data['is_retired']!, _isRetiredMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gear map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gear(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      gearType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gear_type'],
      )!,
      brandModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_model'],
      ),
      totalDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_distance_meters'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isRetired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_retired'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GearsTable createAlias(String alias) {
    return $GearsTable(attachedDatabase, alias);
  }
}

class Gear extends DataClass implements Insertable<Gear> {
  final String id;
  final String? userId;
  final String name;
  final String gearType;
  final String? brandModel;
  final double totalDistanceMeters;
  final bool isDefault;
  final bool isRetired;
  final DateTime createdAt;
  const Gear({
    required this.id,
    this.userId,
    required this.name,
    required this.gearType,
    this.brandModel,
    required this.totalDistanceMeters,
    required this.isDefault,
    required this.isRetired,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    map['gear_type'] = Variable<String>(gearType);
    if (!nullToAbsent || brandModel != null) {
      map['brand_model'] = Variable<String>(brandModel);
    }
    map['total_distance_meters'] = Variable<double>(totalDistanceMeters);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_retired'] = Variable<bool>(isRetired);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GearsCompanion toCompanion(bool nullToAbsent) {
    return GearsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      name: Value(name),
      gearType: Value(gearType),
      brandModel: brandModel == null && nullToAbsent
          ? const Value.absent()
          : Value(brandModel),
      totalDistanceMeters: Value(totalDistanceMeters),
      isDefault: Value(isDefault),
      isRetired: Value(isRetired),
      createdAt: Value(createdAt),
    );
  }

  factory Gear.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gear(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      gearType: serializer.fromJson<String>(json['gearType']),
      brandModel: serializer.fromJson<String?>(json['brandModel']),
      totalDistanceMeters: serializer.fromJson<double>(
        json['totalDistanceMeters'],
      ),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isRetired: serializer.fromJson<bool>(json['isRetired']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'gearType': serializer.toJson<String>(gearType),
      'brandModel': serializer.toJson<String?>(brandModel),
      'totalDistanceMeters': serializer.toJson<double>(totalDistanceMeters),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isRetired': serializer.toJson<bool>(isRetired),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Gear copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? name,
    String? gearType,
    Value<String?> brandModel = const Value.absent(),
    double? totalDistanceMeters,
    bool? isDefault,
    bool? isRetired,
    DateTime? createdAt,
  }) => Gear(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    name: name ?? this.name,
    gearType: gearType ?? this.gearType,
    brandModel: brandModel.present ? brandModel.value : this.brandModel,
    totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
    isDefault: isDefault ?? this.isDefault,
    isRetired: isRetired ?? this.isRetired,
    createdAt: createdAt ?? this.createdAt,
  );
  Gear copyWithCompanion(GearsCompanion data) {
    return Gear(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      gearType: data.gearType.present ? data.gearType.value : this.gearType,
      brandModel: data.brandModel.present
          ? data.brandModel.value
          : this.brandModel,
      totalDistanceMeters: data.totalDistanceMeters.present
          ? data.totalDistanceMeters.value
          : this.totalDistanceMeters,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isRetired: data.isRetired.present ? data.isRetired.value : this.isRetired,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gear(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('gearType: $gearType, ')
          ..write('brandModel: $brandModel, ')
          ..write('totalDistanceMeters: $totalDistanceMeters, ')
          ..write('isDefault: $isDefault, ')
          ..write('isRetired: $isRetired, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    gearType,
    brandModel,
    totalDistanceMeters,
    isDefault,
    isRetired,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gear &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.gearType == this.gearType &&
          other.brandModel == this.brandModel &&
          other.totalDistanceMeters == this.totalDistanceMeters &&
          other.isDefault == this.isDefault &&
          other.isRetired == this.isRetired &&
          other.createdAt == this.createdAt);
}

class GearsCompanion extends UpdateCompanion<Gear> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> name;
  final Value<String> gearType;
  final Value<String?> brandModel;
  final Value<double> totalDistanceMeters;
  final Value<bool> isDefault;
  final Value<bool> isRetired;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GearsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.gearType = const Value.absent(),
    this.brandModel = const Value.absent(),
    this.totalDistanceMeters = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isRetired = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GearsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String name,
    required String gearType,
    this.brandModel = const Value.absent(),
    this.totalDistanceMeters = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isRetired = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       gearType = Value(gearType),
       createdAt = Value(createdAt);
  static Insertable<Gear> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? gearType,
    Expression<String>? brandModel,
    Expression<double>? totalDistanceMeters,
    Expression<bool>? isDefault,
    Expression<bool>? isRetired,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (gearType != null) 'gear_type': gearType,
      if (brandModel != null) 'brand_model': brandModel,
      if (totalDistanceMeters != null)
        'total_distance_meters': totalDistanceMeters,
      if (isDefault != null) 'is_default': isDefault,
      if (isRetired != null) 'is_retired': isRetired,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GearsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? name,
    Value<String>? gearType,
    Value<String?>? brandModel,
    Value<double>? totalDistanceMeters,
    Value<bool>? isDefault,
    Value<bool>? isRetired,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GearsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      gearType: gearType ?? this.gearType,
      brandModel: brandModel ?? this.brandModel,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      isDefault: isDefault ?? this.isDefault,
      isRetired: isRetired ?? this.isRetired,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gearType.present) {
      map['gear_type'] = Variable<String>(gearType.value);
    }
    if (brandModel.present) {
      map['brand_model'] = Variable<String>(brandModel.value);
    }
    if (totalDistanceMeters.present) {
      map['total_distance_meters'] = Variable<double>(
        totalDistanceMeters.value,
      );
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isRetired.present) {
      map['is_retired'] = Variable<bool>(isRetired.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GearsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('gearType: $gearType, ')
          ..write('brandModel: $brandModel, ')
          ..write('totalDistanceMeters: $totalDistanceMeters, ')
          ..write('isDefault: $isDefault, ')
          ..write('isRetired: $isRetired, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(70.0),
  );
  static const VerificationMeta _maxHeartRateMeta = const VerificationMeta(
    'maxHeartRate',
  );
  @override
  late final GeneratedColumn<int> maxHeartRate = GeneratedColumn<int>(
    'max_heart_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(190),
  );
  static const VerificationMeta _ftpWattsMeta = const VerificationMeta(
    'ftpWatts',
  );
  @override
  late final GeneratedColumn<int> ftpWatts = GeneratedColumn<int>(
    'ftp_watts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredUnitMeta = const VerificationMeta(
    'preferredUnit',
  );
  @override
  late final GeneratedColumn<String> preferredUnit = GeneratedColumn<String>(
    'preferred_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('metric'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    weightKg,
    maxHeartRate,
    ftpWatts,
    preferredUnit,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('max_heart_rate')) {
      context.handle(
        _maxHeartRateMeta,
        maxHeartRate.isAcceptableOrUnknown(
          data['max_heart_rate']!,
          _maxHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('ftp_watts')) {
      context.handle(
        _ftpWattsMeta,
        ftpWatts.isAcceptableOrUnknown(data['ftp_watts']!, _ftpWattsMeta),
      );
    }
    if (data.containsKey('preferred_unit')) {
      context.handle(
        _preferredUnitMeta,
        preferredUnit.isAcceptableOrUnknown(
          data['preferred_unit']!,
          _preferredUnitMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      maxHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_heart_rate'],
      )!,
      ftpWatts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ftp_watts'],
      ),
      preferredUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_unit'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String displayName;
  final double weightKg;
  final int maxHeartRate;
  final int? ftpWatts;
  final String preferredUnit;
  final DateTime createdAt;
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.weightKg,
    required this.maxHeartRate,
    this.ftpWatts,
    required this.preferredUnit,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['weight_kg'] = Variable<double>(weightKg);
    map['max_heart_rate'] = Variable<int>(maxHeartRate);
    if (!nullToAbsent || ftpWatts != null) {
      map['ftp_watts'] = Variable<int>(ftpWatts);
    }
    map['preferred_unit'] = Variable<String>(preferredUnit);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      weightKg: Value(weightKg),
      maxHeartRate: Value(maxHeartRate),
      ftpWatts: ftpWatts == null && nullToAbsent
          ? const Value.absent()
          : Value(ftpWatts),
      preferredUnit: Value(preferredUnit),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      maxHeartRate: serializer.fromJson<int>(json['maxHeartRate']),
      ftpWatts: serializer.fromJson<int?>(json['ftpWatts']),
      preferredUnit: serializer.fromJson<String>(json['preferredUnit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'weightKg': serializer.toJson<double>(weightKg),
      'maxHeartRate': serializer.toJson<int>(maxHeartRate),
      'ftpWatts': serializer.toJson<int?>(ftpWatts),
      'preferredUnit': serializer.toJson<String>(preferredUnit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    double? weightKg,
    int? maxHeartRate,
    Value<int?> ftpWatts = const Value.absent(),
    String? preferredUnit,
    DateTime? createdAt,
  }) => UserProfile(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    weightKg: weightKg ?? this.weightKg,
    maxHeartRate: maxHeartRate ?? this.maxHeartRate,
    ftpWatts: ftpWatts.present ? ftpWatts.value : this.ftpWatts,
    preferredUnit: preferredUnit ?? this.preferredUnit,
    createdAt: createdAt ?? this.createdAt,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      maxHeartRate: data.maxHeartRate.present
          ? data.maxHeartRate.value
          : this.maxHeartRate,
      ftpWatts: data.ftpWatts.present ? data.ftpWatts.value : this.ftpWatts,
      preferredUnit: data.preferredUnit.present
          ? data.preferredUnit.value
          : this.preferredUnit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('weightKg: $weightKg, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('ftpWatts: $ftpWatts, ')
          ..write('preferredUnit: $preferredUnit, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    weightKg,
    maxHeartRate,
    ftpWatts,
    preferredUnit,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.weightKg == this.weightKg &&
          other.maxHeartRate == this.maxHeartRate &&
          other.ftpWatts == this.ftpWatts &&
          other.preferredUnit == this.preferredUnit &&
          other.createdAt == this.createdAt);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<double> weightKg;
  final Value<int> maxHeartRate;
  final Value<int?> ftpWatts;
  final Value<String> preferredUnit;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.ftpWatts = const Value.absent(),
    this.preferredUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String displayName,
    this.weightKg = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.ftpWatts = const Value.absent(),
    this.preferredUnit = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       createdAt = Value(createdAt);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<double>? weightKg,
    Expression<int>? maxHeartRate,
    Expression<int>? ftpWatts,
    Expression<String>? preferredUnit,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (weightKg != null) 'weight_kg': weightKg,
      if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
      if (ftpWatts != null) 'ftp_watts': ftpWatts,
      if (preferredUnit != null) 'preferred_unit': preferredUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<double>? weightKg,
    Value<int>? maxHeartRate,
    Value<int?>? ftpWatts,
    Value<String>? preferredUnit,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      weightKg: weightKg ?? this.weightKg,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      ftpWatts: ftpWatts ?? this.ftpWatts,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (maxHeartRate.present) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate.value);
    }
    if (ftpWatts.present) {
      map['ftp_watts'] = Variable<int>(ftpWatts.value);
    }
    if (preferredUnit.present) {
      map['preferred_unit'] = Variable<String>(preferredUnit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('weightKg: $weightKg, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('ftpWatts: $ftpWatts, ')
          ..write('preferredUnit: $preferredUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SegmentsTable extends Segments with TableInfo<$SegmentsTable, Segment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sportTypeMeta = const VerificationMeta(
    'sportType',
  );
  @override
  late final GeneratedColumn<String> sportType = GeneratedColumn<String>(
    'sport_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _polylineJsonMeta = const VerificationMeta(
    'polylineJson',
  );
  @override
  late final GeneratedColumn<String> polylineJson = GeneratedColumn<String>(
    'polyline_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startLatMeta = const VerificationMeta(
    'startLat',
  );
  @override
  late final GeneratedColumn<double> startLat = GeneratedColumn<double>(
    'start_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startLonMeta = const VerificationMeta(
    'startLon',
  );
  @override
  late final GeneratedColumn<double> startLon = GeneratedColumn<double>(
    'start_lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endLatMeta = const VerificationMeta('endLat');
  @override
  late final GeneratedColumn<double> endLat = GeneratedColumn<double>(
    'end_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endLonMeta = const VerificationMeta('endLon');
  @override
  late final GeneratedColumn<double> endLon = GeneratedColumn<double>(
    'end_lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sportType,
    polylineJson,
    distanceM,
    startLat,
    startLon,
    endLat,
    endLon,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Segment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sport_type')) {
      context.handle(
        _sportTypeMeta,
        sportType.isAcceptableOrUnknown(data['sport_type']!, _sportTypeMeta),
      );
    }
    if (data.containsKey('polyline_json')) {
      context.handle(
        _polylineJsonMeta,
        polylineJson.isAcceptableOrUnknown(
          data['polyline_json']!,
          _polylineJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_polylineJsonMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('start_lat')) {
      context.handle(
        _startLatMeta,
        startLat.isAcceptableOrUnknown(data['start_lat']!, _startLatMeta),
      );
    } else if (isInserting) {
      context.missing(_startLatMeta);
    }
    if (data.containsKey('start_lon')) {
      context.handle(
        _startLonMeta,
        startLon.isAcceptableOrUnknown(data['start_lon']!, _startLonMeta),
      );
    } else if (isInserting) {
      context.missing(_startLonMeta);
    }
    if (data.containsKey('end_lat')) {
      context.handle(
        _endLatMeta,
        endLat.isAcceptableOrUnknown(data['end_lat']!, _endLatMeta),
      );
    } else if (isInserting) {
      context.missing(_endLatMeta);
    }
    if (data.containsKey('end_lon')) {
      context.handle(
        _endLonMeta,
        endLon.isAcceptableOrUnknown(data['end_lon']!, _endLonMeta),
      );
    } else if (isInserting) {
      context.missing(_endLonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Segment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Segment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sportType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sport_type'],
      ),
      polylineJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polyline_json'],
      )!,
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      )!,
      startLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_lat'],
      )!,
      startLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_lon'],
      )!,
      endLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_lat'],
      )!,
      endLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_lon'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SegmentsTable createAlias(String alias) {
    return $SegmentsTable(attachedDatabase, alias);
  }
}

class Segment extends DataClass implements Insertable<Segment> {
  final String id;
  final String name;
  final String? sportType;

  /// JSON array of [lat, lon] pairs, simplified (~every 10-20 m).
  final String polylineJson;
  final double distanceM;
  final double startLat;
  final double startLon;
  final double endLat;
  final double endLon;
  final DateTime createdAt;
  const Segment({
    required this.id,
    required this.name,
    this.sportType,
    required this.polylineJson,
    required this.distanceM,
    required this.startLat,
    required this.startLon,
    required this.endLat,
    required this.endLon,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sportType != null) {
      map['sport_type'] = Variable<String>(sportType);
    }
    map['polyline_json'] = Variable<String>(polylineJson);
    map['distance_m'] = Variable<double>(distanceM);
    map['start_lat'] = Variable<double>(startLat);
    map['start_lon'] = Variable<double>(startLon);
    map['end_lat'] = Variable<double>(endLat);
    map['end_lon'] = Variable<double>(endLon);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SegmentsCompanion toCompanion(bool nullToAbsent) {
    return SegmentsCompanion(
      id: Value(id),
      name: Value(name),
      sportType: sportType == null && nullToAbsent
          ? const Value.absent()
          : Value(sportType),
      polylineJson: Value(polylineJson),
      distanceM: Value(distanceM),
      startLat: Value(startLat),
      startLon: Value(startLon),
      endLat: Value(endLat),
      endLon: Value(endLon),
      createdAt: Value(createdAt),
    );
  }

  factory Segment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Segment(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sportType: serializer.fromJson<String?>(json['sportType']),
      polylineJson: serializer.fromJson<String>(json['polylineJson']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      startLat: serializer.fromJson<double>(json['startLat']),
      startLon: serializer.fromJson<double>(json['startLon']),
      endLat: serializer.fromJson<double>(json['endLat']),
      endLon: serializer.fromJson<double>(json['endLon']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sportType': serializer.toJson<String?>(sportType),
      'polylineJson': serializer.toJson<String>(polylineJson),
      'distanceM': serializer.toJson<double>(distanceM),
      'startLat': serializer.toJson<double>(startLat),
      'startLon': serializer.toJson<double>(startLon),
      'endLat': serializer.toJson<double>(endLat),
      'endLon': serializer.toJson<double>(endLon),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Segment copyWith({
    String? id,
    String? name,
    Value<String?> sportType = const Value.absent(),
    String? polylineJson,
    double? distanceM,
    double? startLat,
    double? startLon,
    double? endLat,
    double? endLon,
    DateTime? createdAt,
  }) => Segment(
    id: id ?? this.id,
    name: name ?? this.name,
    sportType: sportType.present ? sportType.value : this.sportType,
    polylineJson: polylineJson ?? this.polylineJson,
    distanceM: distanceM ?? this.distanceM,
    startLat: startLat ?? this.startLat,
    startLon: startLon ?? this.startLon,
    endLat: endLat ?? this.endLat,
    endLon: endLon ?? this.endLon,
    createdAt: createdAt ?? this.createdAt,
  );
  Segment copyWithCompanion(SegmentsCompanion data) {
    return Segment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sportType: data.sportType.present ? data.sportType.value : this.sportType,
      polylineJson: data.polylineJson.present
          ? data.polylineJson.value
          : this.polylineJson,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      startLat: data.startLat.present ? data.startLat.value : this.startLat,
      startLon: data.startLon.present ? data.startLon.value : this.startLon,
      endLat: data.endLat.present ? data.endLat.value : this.endLat,
      endLon: data.endLon.present ? data.endLon.value : this.endLon,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Segment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sportType: $sportType, ')
          ..write('polylineJson: $polylineJson, ')
          ..write('distanceM: $distanceM, ')
          ..write('startLat: $startLat, ')
          ..write('startLon: $startLon, ')
          ..write('endLat: $endLat, ')
          ..write('endLon: $endLon, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sportType,
    polylineJson,
    distanceM,
    startLat,
    startLon,
    endLat,
    endLon,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Segment &&
          other.id == this.id &&
          other.name == this.name &&
          other.sportType == this.sportType &&
          other.polylineJson == this.polylineJson &&
          other.distanceM == this.distanceM &&
          other.startLat == this.startLat &&
          other.startLon == this.startLon &&
          other.endLat == this.endLat &&
          other.endLon == this.endLon &&
          other.createdAt == this.createdAt);
}

class SegmentsCompanion extends UpdateCompanion<Segment> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> sportType;
  final Value<String> polylineJson;
  final Value<double> distanceM;
  final Value<double> startLat;
  final Value<double> startLon;
  final Value<double> endLat;
  final Value<double> endLon;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SegmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sportType = const Value.absent(),
    this.polylineJson = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.startLat = const Value.absent(),
    this.startLon = const Value.absent(),
    this.endLat = const Value.absent(),
    this.endLon = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SegmentsCompanion.insert({
    required String id,
    required String name,
    this.sportType = const Value.absent(),
    required String polylineJson,
    required double distanceM,
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       polylineJson = Value(polylineJson),
       distanceM = Value(distanceM),
       startLat = Value(startLat),
       startLon = Value(startLon),
       endLat = Value(endLat),
       endLon = Value(endLon),
       createdAt = Value(createdAt);
  static Insertable<Segment> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? sportType,
    Expression<String>? polylineJson,
    Expression<double>? distanceM,
    Expression<double>? startLat,
    Expression<double>? startLon,
    Expression<double>? endLat,
    Expression<double>? endLon,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sportType != null) 'sport_type': sportType,
      if (polylineJson != null) 'polyline_json': polylineJson,
      if (distanceM != null) 'distance_m': distanceM,
      if (startLat != null) 'start_lat': startLat,
      if (startLon != null) 'start_lon': startLon,
      if (endLat != null) 'end_lat': endLat,
      if (endLon != null) 'end_lon': endLon,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? sportType,
    Value<String>? polylineJson,
    Value<double>? distanceM,
    Value<double>? startLat,
    Value<double>? startLon,
    Value<double>? endLat,
    Value<double>? endLon,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SegmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sportType: sportType ?? this.sportType,
      polylineJson: polylineJson ?? this.polylineJson,
      distanceM: distanceM ?? this.distanceM,
      startLat: startLat ?? this.startLat,
      startLon: startLon ?? this.startLon,
      endLat: endLat ?? this.endLat,
      endLon: endLon ?? this.endLon,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sportType.present) {
      map['sport_type'] = Variable<String>(sportType.value);
    }
    if (polylineJson.present) {
      map['polyline_json'] = Variable<String>(polylineJson.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (startLat.present) {
      map['start_lat'] = Variable<double>(startLat.value);
    }
    if (startLon.present) {
      map['start_lon'] = Variable<double>(startLon.value);
    }
    if (endLat.present) {
      map['end_lat'] = Variable<double>(endLat.value);
    }
    if (endLon.present) {
      map['end_lon'] = Variable<double>(endLon.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SegmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sportType: $sportType, ')
          ..write('polylineJson: $polylineJson, ')
          ..write('distanceM: $distanceM, ')
          ..write('startLat: $startLat, ')
          ..write('startLon: $startLon, ')
          ..write('endLat: $endLat, ')
          ..write('endLon: $endLon, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SegmentEffortsTable extends SegmentEfforts
    with TableInfo<$SegmentEffortsTable, SegmentEffort> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SegmentEffortsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentIdMeta = const VerificationMeta(
    'segmentId',
  );
  @override
  late final GeneratedColumn<String> segmentId = GeneratedColumn<String>(
    'segment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES segments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedSMeta = const VerificationMeta(
    'elapsedS',
  );
  @override
  late final GeneratedColumn<int> elapsedS = GeneratedColumn<int>(
    'elapsed_s',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressJsonMeta = const VerificationMeta(
    'progressJson',
  );
  @override
  late final GeneratedColumn<String> progressJson = GeneratedColumn<String>(
    'progress_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    segmentId,
    activityId,
    elapsedS,
    startedAt,
    progressJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'segment_efforts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SegmentEffort> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('segment_id')) {
      context.handle(
        _segmentIdMeta,
        segmentId.isAcceptableOrUnknown(data['segment_id']!, _segmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_segmentIdMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('elapsed_s')) {
      context.handle(
        _elapsedSMeta,
        elapsedS.isAcceptableOrUnknown(data['elapsed_s']!, _elapsedSMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedSMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('progress_json')) {
      context.handle(
        _progressJsonMeta,
        progressJson.isAcceptableOrUnknown(
          data['progress_json']!,
          _progressJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SegmentEffort map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SegmentEffort(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      segmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      elapsedS: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_s'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      progressJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}progress_json'],
      )!,
    );
  }

  @override
  $SegmentEffortsTable createAlias(String alias) {
    return $SegmentEffortsTable(attachedDatabase, alias);
  }
}

class SegmentEffort extends DataClass implements Insertable<SegmentEffort> {
  final String id;
  final String segmentId;
  final String activityId;
  final int elapsedS;
  final DateTime startedAt;

  /// JSON array of seconds-since-segment-start at each 50 m (ghost replay).
  final String progressJson;
  const SegmentEffort({
    required this.id,
    required this.segmentId,
    required this.activityId,
    required this.elapsedS,
    required this.startedAt,
    required this.progressJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['segment_id'] = Variable<String>(segmentId);
    map['activity_id'] = Variable<String>(activityId);
    map['elapsed_s'] = Variable<int>(elapsedS);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['progress_json'] = Variable<String>(progressJson);
    return map;
  }

  SegmentEffortsCompanion toCompanion(bool nullToAbsent) {
    return SegmentEffortsCompanion(
      id: Value(id),
      segmentId: Value(segmentId),
      activityId: Value(activityId),
      elapsedS: Value(elapsedS),
      startedAt: Value(startedAt),
      progressJson: Value(progressJson),
    );
  }

  factory SegmentEffort.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SegmentEffort(
      id: serializer.fromJson<String>(json['id']),
      segmentId: serializer.fromJson<String>(json['segmentId']),
      activityId: serializer.fromJson<String>(json['activityId']),
      elapsedS: serializer.fromJson<int>(json['elapsedS']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      progressJson: serializer.fromJson<String>(json['progressJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'segmentId': serializer.toJson<String>(segmentId),
      'activityId': serializer.toJson<String>(activityId),
      'elapsedS': serializer.toJson<int>(elapsedS),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'progressJson': serializer.toJson<String>(progressJson),
    };
  }

  SegmentEffort copyWith({
    String? id,
    String? segmentId,
    String? activityId,
    int? elapsedS,
    DateTime? startedAt,
    String? progressJson,
  }) => SegmentEffort(
    id: id ?? this.id,
    segmentId: segmentId ?? this.segmentId,
    activityId: activityId ?? this.activityId,
    elapsedS: elapsedS ?? this.elapsedS,
    startedAt: startedAt ?? this.startedAt,
    progressJson: progressJson ?? this.progressJson,
  );
  SegmentEffort copyWithCompanion(SegmentEffortsCompanion data) {
    return SegmentEffort(
      id: data.id.present ? data.id.value : this.id,
      segmentId: data.segmentId.present ? data.segmentId.value : this.segmentId,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      elapsedS: data.elapsedS.present ? data.elapsedS.value : this.elapsedS,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      progressJson: data.progressJson.present
          ? data.progressJson.value
          : this.progressJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SegmentEffort(')
          ..write('id: $id, ')
          ..write('segmentId: $segmentId, ')
          ..write('activityId: $activityId, ')
          ..write('elapsedS: $elapsedS, ')
          ..write('startedAt: $startedAt, ')
          ..write('progressJson: $progressJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, segmentId, activityId, elapsedS, startedAt, progressJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SegmentEffort &&
          other.id == this.id &&
          other.segmentId == this.segmentId &&
          other.activityId == this.activityId &&
          other.elapsedS == this.elapsedS &&
          other.startedAt == this.startedAt &&
          other.progressJson == this.progressJson);
}

class SegmentEffortsCompanion extends UpdateCompanion<SegmentEffort> {
  final Value<String> id;
  final Value<String> segmentId;
  final Value<String> activityId;
  final Value<int> elapsedS;
  final Value<DateTime> startedAt;
  final Value<String> progressJson;
  final Value<int> rowid;
  const SegmentEffortsCompanion({
    this.id = const Value.absent(),
    this.segmentId = const Value.absent(),
    this.activityId = const Value.absent(),
    this.elapsedS = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.progressJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SegmentEffortsCompanion.insert({
    required String id,
    required String segmentId,
    required String activityId,
    required int elapsedS,
    required DateTime startedAt,
    this.progressJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       segmentId = Value(segmentId),
       activityId = Value(activityId),
       elapsedS = Value(elapsedS),
       startedAt = Value(startedAt);
  static Insertable<SegmentEffort> custom({
    Expression<String>? id,
    Expression<String>? segmentId,
    Expression<String>? activityId,
    Expression<int>? elapsedS,
    Expression<DateTime>? startedAt,
    Expression<String>? progressJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (segmentId != null) 'segment_id': segmentId,
      if (activityId != null) 'activity_id': activityId,
      if (elapsedS != null) 'elapsed_s': elapsedS,
      if (startedAt != null) 'started_at': startedAt,
      if (progressJson != null) 'progress_json': progressJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SegmentEffortsCompanion copyWith({
    Value<String>? id,
    Value<String>? segmentId,
    Value<String>? activityId,
    Value<int>? elapsedS,
    Value<DateTime>? startedAt,
    Value<String>? progressJson,
    Value<int>? rowid,
  }) {
    return SegmentEffortsCompanion(
      id: id ?? this.id,
      segmentId: segmentId ?? this.segmentId,
      activityId: activityId ?? this.activityId,
      elapsedS: elapsedS ?? this.elapsedS,
      startedAt: startedAt ?? this.startedAt,
      progressJson: progressJson ?? this.progressJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (segmentId.present) {
      map['segment_id'] = Variable<String>(segmentId.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (elapsedS.present) {
      map['elapsed_s'] = Variable<int>(elapsedS.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (progressJson.present) {
      map['progress_json'] = Variable<String>(progressJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SegmentEffortsCompanion(')
          ..write('id: $id, ')
          ..write('segmentId: $segmentId, ')
          ..write('activityId: $activityId, ')
          ..write('elapsedS: $elapsedS, ')
          ..write('startedAt: $startedAt, ')
          ..write('progressJson: $progressJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleGroupMeta = const VerificationMeta(
    'muscleGroup',
  );
  @override
  late final GeneratedColumn<String> muscleGroup = GeneratedColumn<String>(
    'muscle_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('lainnya'),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    muscleGroup,
    equipment,
    isCustom,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
        _muscleGroupMeta,
        muscleGroup.isAcceptableOrUnknown(
          data['muscle_group']!,
          _muscleGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      muscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final String id;
  final String name;

  /// dada | punggung | kaki | bahu | lengan | core | lainnya
  final String muscleGroup;

  /// barbel | dumbel | mesin | kabel | badan | lainnya
  final String equipment;
  final bool isCustom;
  final DateTime createdAt;
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.isCustom,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['muscle_group'] = Variable<String>(muscleGroup);
    map['equipment'] = Variable<String>(equipment);
    map['is_custom'] = Variable<bool>(isCustom);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      muscleGroup: Value(muscleGroup),
      equipment: Value(equipment),
      isCustom: Value(isCustom),
      createdAt: Value(createdAt),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      muscleGroup: serializer.fromJson<String>(json['muscleGroup']),
      equipment: serializer.fromJson<String>(json['equipment']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'muscleGroup': serializer.toJson<String>(muscleGroup),
      'equipment': serializer.toJson<String>(equipment),
      'isCustom': serializer.toJson<bool>(isCustom),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? equipment,
    bool? isCustom,
    DateTime? createdAt,
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    equipment: equipment ?? this.equipment,
    isCustom: isCustom ?? this.isCustom,
    createdAt: createdAt ?? this.createdAt,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('equipment: $equipment, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, muscleGroup, equipment, isCustom, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.muscleGroup == this.muscleGroup &&
          other.equipment == this.equipment &&
          other.isCustom == this.isCustom &&
          other.createdAt == this.createdAt);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> muscleGroup;
  final Value<String> equipment;
  final Value<bool> isCustom;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.equipment = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String name,
    required String muscleGroup,
    this.equipment = const Value.absent(),
    this.isCustom = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       muscleGroup = Value(muscleGroup),
       createdAt = Value(createdAt);
  static Insertable<Exercise> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? muscleGroup,
    Expression<String>? equipment,
    Expression<bool>? isCustom,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (equipment != null) 'equipment': equipment,
      if (isCustom != null) 'is_custom': isCustom,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? muscleGroup,
    Value<String>? equipment,
    Value<bool>? isCustom,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(muscleGroup.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('equipment: $equipment, ')
          ..write('isCustom: $isCustom, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityIdMeta = const VerificationMeta(
    'activityId',
  );
  @override
  late final GeneratedColumn<String> activityId = GeneratedColumn<String>(
    'activity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activities (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _exerciseOrderMeta = const VerificationMeta(
    'exerciseOrder',
  );
  @override
  late final GeneratedColumn<int> exerciseOrder = GeneratedColumn<int>(
    'exercise_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isWarmupMeta = const VerificationMeta(
    'isWarmup',
  );
  @override
  late final GeneratedColumn<bool> isWarmup = GeneratedColumn<bool>(
    'is_warmup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_warmup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    activityId,
    exerciseId,
    exerciseOrder,
    setIndex,
    reps,
    weightKg,
    rpe,
    isWarmup,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('activity_id')) {
      context.handle(
        _activityIdMeta,
        activityId.isAcceptableOrUnknown(data['activity_id']!, _activityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_activityIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('exercise_order')) {
      context.handle(
        _exerciseOrderMeta,
        exerciseOrder.isAcceptableOrUnknown(
          data['exercise_order']!,
          _exerciseOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseOrderMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('is_warmup')) {
      context.handle(
        _isWarmupMeta,
        isWarmup.isAcceptableOrUnknown(data['is_warmup']!, _isWarmupMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      activityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      exerciseOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_order'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      ),
      isWarmup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_warmup'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final String id;
  final String activityId;
  final String exerciseId;

  /// Urutan gerakan dalam sesi (0..n) dan urutan set dalam gerakan.
  final int exerciseOrder;
  final int setIndex;

  /// Null = belum diisi (draf sesi yang masih berjalan).
  final int? reps;
  final double? weightKg;
  final double? rpe;
  final bool isWarmup;

  /// Null = set belum dicentang.
  final DateTime? completedAt;
  const WorkoutSet({
    required this.id,
    required this.activityId,
    required this.exerciseId,
    required this.exerciseOrder,
    required this.setIndex,
    this.reps,
    this.weightKg,
    this.rpe,
    required this.isWarmup,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['activity_id'] = Variable<String>(activityId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['exercise_order'] = Variable<int>(exerciseOrder);
    map['set_index'] = Variable<int>(setIndex);
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    map['is_warmup'] = Variable<bool>(isWarmup);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      activityId: Value(activityId),
      exerciseId: Value(exerciseId),
      exerciseOrder: Value(exerciseOrder),
      setIndex: Value(setIndex),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      isWarmup: Value(isWarmup),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory WorkoutSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<String>(json['id']),
      activityId: serializer.fromJson<String>(json['activityId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      exerciseOrder: serializer.fromJson<int>(json['exerciseOrder']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      reps: serializer.fromJson<int?>(json['reps']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      isWarmup: serializer.fromJson<bool>(json['isWarmup']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'activityId': serializer.toJson<String>(activityId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'exerciseOrder': serializer.toJson<int>(exerciseOrder),
      'setIndex': serializer.toJson<int>(setIndex),
      'reps': serializer.toJson<int?>(reps),
      'weightKg': serializer.toJson<double?>(weightKg),
      'rpe': serializer.toJson<double?>(rpe),
      'isWarmup': serializer.toJson<bool>(isWarmup),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  WorkoutSet copyWith({
    String? id,
    String? activityId,
    String? exerciseId,
    int? exerciseOrder,
    int? setIndex,
    Value<int?> reps = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
    bool? isWarmup,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => WorkoutSet(
    id: id ?? this.id,
    activityId: activityId ?? this.activityId,
    exerciseId: exerciseId ?? this.exerciseId,
    exerciseOrder: exerciseOrder ?? this.exerciseOrder,
    setIndex: setIndex ?? this.setIndex,
    reps: reps.present ? reps.value : this.reps,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    rpe: rpe.present ? rpe.value : this.rpe,
    isWarmup: isWarmup ?? this.isWarmup,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      activityId: data.activityId.present
          ? data.activityId.value
          : this.activityId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseOrder: data.exerciseOrder.present
          ? data.exerciseOrder.value
          : this.exerciseOrder,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      reps: data.reps.present ? data.reps.value : this.reps,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      isWarmup: data.isWarmup.present ? data.isWarmup.value : this.isWarmup,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseOrder: $exerciseOrder, ')
          ..write('setIndex: $setIndex, ')
          ..write('reps: $reps, ')
          ..write('weightKg: $weightKg, ')
          ..write('rpe: $rpe, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    activityId,
    exerciseId,
    exerciseOrder,
    setIndex,
    reps,
    weightKg,
    rpe,
    isWarmup,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.activityId == this.activityId &&
          other.exerciseId == this.exerciseId &&
          other.exerciseOrder == this.exerciseOrder &&
          other.setIndex == this.setIndex &&
          other.reps == this.reps &&
          other.weightKg == this.weightKg &&
          other.rpe == this.rpe &&
          other.isWarmup == this.isWarmup &&
          other.completedAt == this.completedAt);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<String> id;
  final Value<String> activityId;
  final Value<String> exerciseId;
  final Value<int> exerciseOrder;
  final Value<int> setIndex;
  final Value<int?> reps;
  final Value<double?> weightKg;
  final Value<double?> rpe;
  final Value<bool> isWarmup;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.activityId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseOrder = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.reps = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.rpe = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    required String id,
    required String activityId,
    required String exerciseId,
    required int exerciseOrder,
    required int setIndex,
    this.reps = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.rpe = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       activityId = Value(activityId),
       exerciseId = Value(exerciseId),
       exerciseOrder = Value(exerciseOrder),
       setIndex = Value(setIndex);
  static Insertable<WorkoutSet> custom({
    Expression<String>? id,
    Expression<String>? activityId,
    Expression<String>? exerciseId,
    Expression<int>? exerciseOrder,
    Expression<int>? setIndex,
    Expression<int>? reps,
    Expression<double>? weightKg,
    Expression<double>? rpe,
    Expression<bool>? isWarmup,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (activityId != null) 'activity_id': activityId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseOrder != null) 'exercise_order': exerciseOrder,
      if (setIndex != null) 'set_index': setIndex,
      if (reps != null) 'reps': reps,
      if (weightKg != null) 'weight_kg': weightKg,
      if (rpe != null) 'rpe': rpe,
      if (isWarmup != null) 'is_warmup': isWarmup,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? activityId,
    Value<String>? exerciseId,
    Value<int>? exerciseOrder,
    Value<int>? setIndex,
    Value<int?>? reps,
    Value<double?>? weightKg,
    Value<double?>? rpe,
    Value<bool>? isWarmup,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseOrder: exerciseOrder ?? this.exerciseOrder,
      setIndex: setIndex ?? this.setIndex,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (activityId.present) {
      map['activity_id'] = Variable<String>(activityId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (exerciseOrder.present) {
      map['exercise_order'] = Variable<int>(exerciseOrder.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (isWarmup.present) {
      map['is_warmup'] = Variable<bool>(isWarmup.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('activityId: $activityId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseOrder: $exerciseOrder, ')
          ..write('setIndex: $setIndex, ')
          ..write('reps: $reps, ')
          ..write('weightKg: $weightKg, ')
          ..write('rpe: $rpe, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTemplatesTable extends WorkoutTemplates
    with TableInfo<$WorkoutTemplatesTable, WorkoutTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, note, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkoutTemplatesTable createAlias(String alias) {
    return $WorkoutTemplatesTable(attachedDatabase, alias);
  }
}

class WorkoutTemplate extends DataClass implements Insertable<WorkoutTemplate> {
  final String id;
  final String name;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkoutTemplate({
    required this.id,
    required this.name,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkoutTemplatesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkoutTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutTemplate(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkoutTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkoutTemplate copyWithCompanion(WorkoutTemplatesCompanion data) {
    return WorkoutTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, note, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkoutTemplatesCompanion extends UpdateCompanion<WorkoutTemplate> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkoutTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutTemplatesCompanion.insert({
    required String id,
    required String name,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WorkoutTemplate> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkoutTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutTemplateItemsTable extends WorkoutTemplateItems
    with TableInfo<$WorkoutTemplateItemsTable, WorkoutTemplateItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutTemplateItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_templates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _itemOrderMeta = const VerificationMeta(
    'itemOrder',
  );
  @override
  late final GeneratedColumn<int> itemOrder = GeneratedColumn<int>(
    'item_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta(
    'targetReps',
  );
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    exerciseId,
    itemOrder,
    targetSets,
    targetReps,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_template_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutTemplateItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('item_order')) {
      context.handle(
        _itemOrderMeta,
        itemOrder.isAcceptableOrUnknown(data['item_order']!, _itemOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_itemOrderMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    }
    if (data.containsKey('target_reps')) {
      context.handle(
        _targetRepsMeta,
        targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutTemplateItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutTemplateItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      itemOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_order'],
      )!,
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      )!,
      targetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps'],
      )!,
    );
  }

  @override
  $WorkoutTemplateItemsTable createAlias(String alias) {
    return $WorkoutTemplateItemsTable(attachedDatabase, alias);
  }
}

class WorkoutTemplateItem extends DataClass
    implements Insertable<WorkoutTemplateItem> {
  final String id;
  final String templateId;
  final String exerciseId;
  final int itemOrder;
  final int targetSets;
  final int targetReps;
  const WorkoutTemplateItem({
    required this.id,
    required this.templateId,
    required this.exerciseId,
    required this.itemOrder,
    required this.targetSets,
    required this.targetReps,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['item_order'] = Variable<int>(itemOrder);
    map['target_sets'] = Variable<int>(targetSets);
    map['target_reps'] = Variable<int>(targetReps);
    return map;
  }

  WorkoutTemplateItemsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutTemplateItemsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      exerciseId: Value(exerciseId),
      itemOrder: Value(itemOrder),
      targetSets: Value(targetSets),
      targetReps: Value(targetReps),
    );
  }

  factory WorkoutTemplateItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutTemplateItem(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      itemOrder: serializer.fromJson<int>(json['itemOrder']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      targetReps: serializer.fromJson<int>(json['targetReps']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'itemOrder': serializer.toJson<int>(itemOrder),
      'targetSets': serializer.toJson<int>(targetSets),
      'targetReps': serializer.toJson<int>(targetReps),
    };
  }

  WorkoutTemplateItem copyWith({
    String? id,
    String? templateId,
    String? exerciseId,
    int? itemOrder,
    int? targetSets,
    int? targetReps,
  }) => WorkoutTemplateItem(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    exerciseId: exerciseId ?? this.exerciseId,
    itemOrder: itemOrder ?? this.itemOrder,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps ?? this.targetReps,
  );
  WorkoutTemplateItem copyWithCompanion(WorkoutTemplateItemsCompanion data) {
    return WorkoutTemplateItem(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      itemOrder: data.itemOrder.present ? data.itemOrder.value : this.itemOrder,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      targetReps: data.targetReps.present
          ? data.targetReps.value
          : this.targetReps,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplateItem(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('itemOrder: $itemOrder, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    exerciseId,
    itemOrder,
    targetSets,
    targetReps,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutTemplateItem &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.exerciseId == this.exerciseId &&
          other.itemOrder == this.itemOrder &&
          other.targetSets == this.targetSets &&
          other.targetReps == this.targetReps);
}

class WorkoutTemplateItemsCompanion
    extends UpdateCompanion<WorkoutTemplateItem> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> exerciseId;
  final Value<int> itemOrder;
  final Value<int> targetSets;
  final Value<int> targetReps;
  final Value<int> rowid;
  const WorkoutTemplateItemsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.itemOrder = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutTemplateItemsCompanion.insert({
    required String id,
    required String templateId,
    required String exerciseId,
    required int itemOrder,
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       exerciseId = Value(exerciseId),
       itemOrder = Value(itemOrder);
  static Insertable<WorkoutTemplateItem> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? exerciseId,
    Expression<int>? itemOrder,
    Expression<int>? targetSets,
    Expression<int>? targetReps,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (itemOrder != null) 'item_order': itemOrder,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetReps != null) 'target_reps': targetReps,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutTemplateItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? exerciseId,
    Value<int>? itemOrder,
    Value<int>? targetSets,
    Value<int>? targetReps,
    Value<int>? rowid,
  }) {
    return WorkoutTemplateItemsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      exerciseId: exerciseId ?? this.exerciseId,
      itemOrder: itemOrder ?? this.itemOrder,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (itemOrder.present) {
      map['item_order'] = Variable<int>(itemOrder.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutTemplateItemsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('itemOrder: $itemOrder, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $TrackPointsTable trackPoints = $TrackPointsTable(this);
  late final $WaypointPhotosTable waypointPhotos = $WaypointPhotosTable(this);
  late final $GearsTable gears = $GearsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $SegmentsTable segments = $SegmentsTable(this);
  late final $SegmentEffortsTable segmentEfforts = $SegmentEffortsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $WorkoutTemplatesTable workoutTemplates = $WorkoutTemplatesTable(
    this,
  );
  late final $WorkoutTemplateItemsTable workoutTemplateItems =
      $WorkoutTemplateItemsTable(this);
  late final ActivitiesDao activitiesDao = ActivitiesDao(this as AppDatabase);
  late final TrackPointsDao trackPointsDao = TrackPointsDao(
    this as AppDatabase,
  );
  late final WaypointPhotosDao waypointPhotosDao = WaypointPhotosDao(
    this as AppDatabase,
  );
  late final GearsDao gearsDao = GearsDao(this as AppDatabase);
  late final GymDao gymDao = GymDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    activities,
    trackPoints,
    waypointPhotos,
    gears,
    userProfiles,
    segments,
    segmentEfforts,
    appSettings,
    exercises,
    workoutSets,
    workoutTemplates,
    workoutTemplateItems,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_points', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('waypoint_photos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'segments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('segment_efforts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'activities',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_templates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_template_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      required String id,
      Value<String?> userId,
      Value<String?> gearId,
      required String title,
      Value<String?> description,
      required String sportType,
      required String status,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<double> totalDistanceMeters,
      Value<int> elapsedTimeSeconds,
      Value<int> movingTimeSeconds,
      Value<double> elevationGainMeters,
      Value<double> elevationLossMeters,
      Value<double> maxElevationMeters,
      Value<double> minElevationMeters,
      Value<double> avgSpeedMps,
      Value<double> maxSpeedMps,
      Value<double?> avgGapMps,
      Value<int?> avgCadence,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<int?> estimatedEnergyKj,
      Value<double> gravelPercentage,
      Value<double> asphaltPercentage,
      Value<double> relativeEffort,
      Value<double> gritScore,
      Value<double?> avgPowerW,
      Value<String> source,
      Value<String?> primaryPhotoPath,
      Value<bool> isFavorite,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String?> gearId,
      Value<String> title,
      Value<String?> description,
      Value<String> sportType,
      Value<String> status,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<double> totalDistanceMeters,
      Value<int> elapsedTimeSeconds,
      Value<int> movingTimeSeconds,
      Value<double> elevationGainMeters,
      Value<double> elevationLossMeters,
      Value<double> maxElevationMeters,
      Value<double> minElevationMeters,
      Value<double> avgSpeedMps,
      Value<double> maxSpeedMps,
      Value<double?> avgGapMps,
      Value<int?> avgCadence,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<int?> estimatedEnergyKj,
      Value<double> gravelPercentage,
      Value<double> asphaltPercentage,
      Value<double> relativeEffort,
      Value<double> gritScore,
      Value<double?> avgPowerW,
      Value<String> source,
      Value<String?> primaryPhotoPath,
      Value<bool> isFavorite,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrackPointsTable, List<TrackPoint>>
  _trackPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackPoints,
    aliasName: $_aliasNameGenerator(
      db.activities.id,
      db.trackPoints.activityId,
    ),
  );

  $$TrackPointsTableProcessedTableManager get trackPointsRefs {
    final manager = $$TrackPointsTableTableManager(
      $_db,
      $_db.trackPoints,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WaypointPhotosTable, List<WaypointPhoto>>
  _waypointPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.waypointPhotos,
    aliasName: $_aliasNameGenerator(
      db.activities.id,
      db.waypointPhotos.activityId,
    ),
  );

  $$WaypointPhotosTableProcessedTableManager get waypointPhotosRefs {
    final manager = $$WaypointPhotosTableTableManager(
      $_db,
      $_db.waypointPhotos,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_waypointPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
  _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSets,
    aliasName: $_aliasNameGenerator(
      db.activities.id,
      db.workoutSets.activityId,
    ),
  );

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager(
      $_db,
      $_db.workoutSets,
    ).filter((f) => f.activityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gearId => $composableBuilder(
    column: $table.gearId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sportType => $composableBuilder(
    column: $table.sportType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDistanceMeters => $composableBuilder(
    column: $table.totalDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedTimeSeconds => $composableBuilder(
    column: $table.elapsedTimeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movingTimeSeconds => $composableBuilder(
    column: $table.movingTimeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationLossMeters => $composableBuilder(
    column: $table.elevationLossMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxElevationMeters => $composableBuilder(
    column: $table.maxElevationMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minElevationMeters => $composableBuilder(
    column: $table.minElevationMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxSpeedMps => $composableBuilder(
    column: $table.maxSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgGapMps => $composableBuilder(
    column: $table.avgGapMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedEnergyKj => $composableBuilder(
    column: $table.estimatedEnergyKj,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gravelPercentage => $composableBuilder(
    column: $table.gravelPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get asphaltPercentage => $composableBuilder(
    column: $table.asphaltPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get relativeEffort => $composableBuilder(
    column: $table.relativeEffort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gritScore => $composableBuilder(
    column: $table.gritScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgPowerW => $composableBuilder(
    column: $table.avgPowerW,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryPhotoPath => $composableBuilder(
    column: $table.primaryPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackPointsRefs(
    Expression<bool> Function($$TrackPointsTableFilterComposer f) f,
  ) {
    final $$TrackPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableFilterComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> waypointPhotosRefs(
    Expression<bool> Function($$WaypointPhotosTableFilterComposer f) f,
  ) {
    final $$WaypointPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.waypointPhotos,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaypointPhotosTableFilterComposer(
            $db: $db,
            $table: $db.waypointPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSetsRefs(
    Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gearId => $composableBuilder(
    column: $table.gearId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sportType => $composableBuilder(
    column: $table.sportType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDistanceMeters => $composableBuilder(
    column: $table.totalDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedTimeSeconds => $composableBuilder(
    column: $table.elapsedTimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movingTimeSeconds => $composableBuilder(
    column: $table.movingTimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationLossMeters => $composableBuilder(
    column: $table.elevationLossMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxElevationMeters => $composableBuilder(
    column: $table.maxElevationMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minElevationMeters => $composableBuilder(
    column: $table.minElevationMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxSpeedMps => $composableBuilder(
    column: $table.maxSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgGapMps => $composableBuilder(
    column: $table.avgGapMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedEnergyKj => $composableBuilder(
    column: $table.estimatedEnergyKj,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gravelPercentage => $composableBuilder(
    column: $table.gravelPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get asphaltPercentage => $composableBuilder(
    column: $table.asphaltPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get relativeEffort => $composableBuilder(
    column: $table.relativeEffort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gritScore => $composableBuilder(
    column: $table.gritScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgPowerW => $composableBuilder(
    column: $table.avgPowerW,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryPhotoPath => $composableBuilder(
    column: $table.primaryPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get gearId =>
      $composableBuilder(column: $table.gearId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sportType =>
      $composableBuilder(column: $table.sportType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<double> get totalDistanceMeters => $composableBuilder(
    column: $table.totalDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedTimeSeconds => $composableBuilder(
    column: $table.elapsedTimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get movingTimeSeconds => $composableBuilder(
    column: $table.movingTimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationLossMeters => $composableBuilder(
    column: $table.elevationLossMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxElevationMeters => $composableBuilder(
    column: $table.maxElevationMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minElevationMeters => $composableBuilder(
    column: $table.minElevationMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxSpeedMps => $composableBuilder(
    column: $table.maxSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgGapMps =>
      $composableBuilder(column: $table.avgGapMps, builder: (column) => column);

  GeneratedColumn<int> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedEnergyKj => $composableBuilder(
    column: $table.estimatedEnergyKj,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gravelPercentage => $composableBuilder(
    column: $table.gravelPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get asphaltPercentage => $composableBuilder(
    column: $table.asphaltPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get relativeEffort => $composableBuilder(
    column: $table.relativeEffort,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gritScore =>
      $composableBuilder(column: $table.gritScore, builder: (column) => column);

  GeneratedColumn<double> get avgPowerW =>
      $composableBuilder(column: $table.avgPowerW, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get primaryPhotoPath => $composableBuilder(
    column: $table.primaryPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> trackPointsRefs<T extends Object>(
    Expression<T> Function($$TrackPointsTableAnnotationComposer a) f,
  ) {
    final $$TrackPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> waypointPhotosRefs<T extends Object>(
    Expression<T> Function($$WaypointPhotosTableAnnotationComposer a) f,
  ) {
    final $$WaypointPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.waypointPhotos,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WaypointPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.waypointPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.activityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({
            bool trackPointsRefs,
            bool waypointPhotosRefs,
            bool workoutSetsRefs,
          })
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> gearId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> sportType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<double> totalDistanceMeters = const Value.absent(),
                Value<int> elapsedTimeSeconds = const Value.absent(),
                Value<int> movingTimeSeconds = const Value.absent(),
                Value<double> elevationGainMeters = const Value.absent(),
                Value<double> elevationLossMeters = const Value.absent(),
                Value<double> maxElevationMeters = const Value.absent(),
                Value<double> minElevationMeters = const Value.absent(),
                Value<double> avgSpeedMps = const Value.absent(),
                Value<double> maxSpeedMps = const Value.absent(),
                Value<double?> avgGapMps = const Value.absent(),
                Value<int?> avgCadence = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<int?> estimatedEnergyKj = const Value.absent(),
                Value<double> gravelPercentage = const Value.absent(),
                Value<double> asphaltPercentage = const Value.absent(),
                Value<double> relativeEffort = const Value.absent(),
                Value<double> gritScore = const Value.absent(),
                Value<double?> avgPowerW = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> primaryPhotoPath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                userId: userId,
                gearId: gearId,
                title: title,
                description: description,
                sportType: sportType,
                status: status,
                startTime: startTime,
                endTime: endTime,
                totalDistanceMeters: totalDistanceMeters,
                elapsedTimeSeconds: elapsedTimeSeconds,
                movingTimeSeconds: movingTimeSeconds,
                elevationGainMeters: elevationGainMeters,
                elevationLossMeters: elevationLossMeters,
                maxElevationMeters: maxElevationMeters,
                minElevationMeters: minElevationMeters,
                avgSpeedMps: avgSpeedMps,
                maxSpeedMps: maxSpeedMps,
                avgGapMps: avgGapMps,
                avgCadence: avgCadence,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                estimatedEnergyKj: estimatedEnergyKj,
                gravelPercentage: gravelPercentage,
                asphaltPercentage: asphaltPercentage,
                relativeEffort: relativeEffort,
                gritScore: gritScore,
                avgPowerW: avgPowerW,
                source: source,
                primaryPhotoPath: primaryPhotoPath,
                isFavorite: isFavorite,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                Value<String?> gearId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required String sportType,
                required String status,
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<double> totalDistanceMeters = const Value.absent(),
                Value<int> elapsedTimeSeconds = const Value.absent(),
                Value<int> movingTimeSeconds = const Value.absent(),
                Value<double> elevationGainMeters = const Value.absent(),
                Value<double> elevationLossMeters = const Value.absent(),
                Value<double> maxElevationMeters = const Value.absent(),
                Value<double> minElevationMeters = const Value.absent(),
                Value<double> avgSpeedMps = const Value.absent(),
                Value<double> maxSpeedMps = const Value.absent(),
                Value<double?> avgGapMps = const Value.absent(),
                Value<int?> avgCadence = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<int?> estimatedEnergyKj = const Value.absent(),
                Value<double> gravelPercentage = const Value.absent(),
                Value<double> asphaltPercentage = const Value.absent(),
                Value<double> relativeEffort = const Value.absent(),
                Value<double> gritScore = const Value.absent(),
                Value<double?> avgPowerW = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> primaryPhotoPath = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                userId: userId,
                gearId: gearId,
                title: title,
                description: description,
                sportType: sportType,
                status: status,
                startTime: startTime,
                endTime: endTime,
                totalDistanceMeters: totalDistanceMeters,
                elapsedTimeSeconds: elapsedTimeSeconds,
                movingTimeSeconds: movingTimeSeconds,
                elevationGainMeters: elevationGainMeters,
                elevationLossMeters: elevationLossMeters,
                maxElevationMeters: maxElevationMeters,
                minElevationMeters: minElevationMeters,
                avgSpeedMps: avgSpeedMps,
                maxSpeedMps: maxSpeedMps,
                avgGapMps: avgGapMps,
                avgCadence: avgCadence,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                estimatedEnergyKj: estimatedEnergyKj,
                gravelPercentage: gravelPercentage,
                asphaltPercentage: asphaltPercentage,
                relativeEffort: relativeEffort,
                gritScore: gritScore,
                avgPowerW: avgPowerW,
                source: source,
                primaryPhotoPath: primaryPhotoPath,
                isFavorite: isFavorite,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                trackPointsRefs = false,
                waypointPhotosRefs = false,
                workoutSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackPointsRefs) db.trackPoints,
                    if (waypointPhotosRefs) db.waypointPhotos,
                    if (workoutSetsRefs) db.workoutSets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackPointsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$ActivitiesTableReferences
                              ._trackPointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).trackPointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (waypointPhotosRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$ActivitiesTableReferences
                              ._waypointPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).waypointPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutSetsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$ActivitiesTableReferences
                              ._workoutSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ActivitiesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.activityId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({
        bool trackPointsRefs,
        bool waypointPhotosRefs,
        bool workoutSetsRefs,
      })
    >;
typedef $$TrackPointsTableCreateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      required String activityId,
      required int sequenceIdx,
      required DateTime timestamp,
      required double latitude,
      required double longitude,
      required double altitudeMeters,
      required double accuracyMeters,
      required double speedMps,
      Value<double> bearingDegrees,
      Value<double> gradePct,
      Value<String> surfaceType,
      Value<double> vibrationRaw,
      Value<int?> heartRate,
      Value<int?> cadence,
      Value<bool> isPaused,
    });
typedef $$TrackPointsTableUpdateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      Value<String> activityId,
      Value<int> sequenceIdx,
      Value<DateTime> timestamp,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> altitudeMeters,
      Value<double> accuracyMeters,
      Value<double> speedMps,
      Value<double> bearingDegrees,
      Value<double> gradePct,
      Value<String> surfaceType,
      Value<double> vibrationRaw,
      Value<int?> heartRate,
      Value<int?> cadence,
      Value<bool> isPaused,
    });

final class $$TrackPointsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackPointsTable, TrackPoint> {
  $$TrackPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias(
        $_aliasNameGenerator(db.trackPoints.activityId, db.activities.id),
      );

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackPointsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceIdx => $composableBuilder(
    column: $table.sequenceIdx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bearingDegrees => $composableBuilder(
    column: $table.bearingDegrees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gradePct => $composableBuilder(
    column: $table.gradePct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surfaceType => $composableBuilder(
    column: $table.surfaceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vibrationRaw => $composableBuilder(
    column: $table.vibrationRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceIdx => $composableBuilder(
    column: $table.sequenceIdx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bearingDegrees => $composableBuilder(
    column: $table.bearingDegrees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gradePct => $composableBuilder(
    column: $table.gradePct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surfaceType => $composableBuilder(
    column: $table.surfaceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vibrationRaw => $composableBuilder(
    column: $table.vibrationRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRate => $composableBuilder(
    column: $table.heartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaused => $composableBuilder(
    column: $table.isPaused,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequenceIdx => $composableBuilder(
    column: $table.sequenceIdx,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speedMps =>
      $composableBuilder(column: $table.speedMps, builder: (column) => column);

  GeneratedColumn<double> get bearingDegrees => $composableBuilder(
    column: $table.bearingDegrees,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gradePct =>
      $composableBuilder(column: $table.gradePct, builder: (column) => column);

  GeneratedColumn<String> get surfaceType => $composableBuilder(
    column: $table.surfaceType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get vibrationRaw => $composableBuilder(
    column: $table.vibrationRaw,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heartRate =>
      $composableBuilder(column: $table.heartRate, builder: (column) => column);

  GeneratedColumn<int> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumn<bool> get isPaused =>
      $composableBuilder(column: $table.isPaused, builder: (column) => column);

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackPointsTable,
          TrackPoint,
          $$TrackPointsTableFilterComposer,
          $$TrackPointsTableOrderingComposer,
          $$TrackPointsTableAnnotationComposer,
          $$TrackPointsTableCreateCompanionBuilder,
          $$TrackPointsTableUpdateCompanionBuilder,
          (TrackPoint, $$TrackPointsTableReferences),
          TrackPoint,
          PrefetchHooks Function({bool activityId})
        > {
  $$TrackPointsTableTableManager(_$AppDatabase db, $TrackPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<int> sequenceIdx = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> altitudeMeters = const Value.absent(),
                Value<double> accuracyMeters = const Value.absent(),
                Value<double> speedMps = const Value.absent(),
                Value<double> bearingDegrees = const Value.absent(),
                Value<double> gradePct = const Value.absent(),
                Value<String> surfaceType = const Value.absent(),
                Value<double> vibrationRaw = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<int?> cadence = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
              }) => TrackPointsCompanion(
                id: id,
                activityId: activityId,
                sequenceIdx: sequenceIdx,
                timestamp: timestamp,
                latitude: latitude,
                longitude: longitude,
                altitudeMeters: altitudeMeters,
                accuracyMeters: accuracyMeters,
                speedMps: speedMps,
                bearingDegrees: bearingDegrees,
                gradePct: gradePct,
                surfaceType: surfaceType,
                vibrationRaw: vibrationRaw,
                heartRate: heartRate,
                cadence: cadence,
                isPaused: isPaused,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String activityId,
                required int sequenceIdx,
                required DateTime timestamp,
                required double latitude,
                required double longitude,
                required double altitudeMeters,
                required double accuracyMeters,
                required double speedMps,
                Value<double> bearingDegrees = const Value.absent(),
                Value<double> gradePct = const Value.absent(),
                Value<String> surfaceType = const Value.absent(),
                Value<double> vibrationRaw = const Value.absent(),
                Value<int?> heartRate = const Value.absent(),
                Value<int?> cadence = const Value.absent(),
                Value<bool> isPaused = const Value.absent(),
              }) => TrackPointsCompanion.insert(
                id: id,
                activityId: activityId,
                sequenceIdx: sequenceIdx,
                timestamp: timestamp,
                latitude: latitude,
                longitude: longitude,
                altitudeMeters: altitudeMeters,
                accuracyMeters: accuracyMeters,
                speedMps: speedMps,
                bearingDegrees: bearingDegrees,
                gradePct: gradePct,
                surfaceType: surfaceType,
                vibrationRaw: vibrationRaw,
                heartRate: heartRate,
                cadence: cadence,
                isPaused: isPaused,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (activityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.activityId,
                                referencedTable: $$TrackPointsTableReferences
                                    ._activityIdTable(db),
                                referencedColumn: $$TrackPointsTableReferences
                                    ._activityIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackPointsTable,
      TrackPoint,
      $$TrackPointsTableFilterComposer,
      $$TrackPointsTableOrderingComposer,
      $$TrackPointsTableAnnotationComposer,
      $$TrackPointsTableCreateCompanionBuilder,
      $$TrackPointsTableUpdateCompanionBuilder,
      (TrackPoint, $$TrackPointsTableReferences),
      TrackPoint,
      PrefetchHooks Function({bool activityId})
    >;
typedef $$WaypointPhotosTableCreateCompanionBuilder =
    WaypointPhotosCompanion Function({
      required String id,
      required String activityId,
      required String filePath,
      required double latitude,
      required double longitude,
      required double altitudeMeters,
      required double distanceFromStartMeters,
      required DateTime takenAt,
      Value<String?> caption,
      Value<int> rowid,
    });
typedef $$WaypointPhotosTableUpdateCompanionBuilder =
    WaypointPhotosCompanion Function({
      Value<String> id,
      Value<String> activityId,
      Value<String> filePath,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> altitudeMeters,
      Value<double> distanceFromStartMeters,
      Value<DateTime> takenAt,
      Value<String?> caption,
      Value<int> rowid,
    });

final class $$WaypointPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $WaypointPhotosTable, WaypointPhoto> {
  $$WaypointPhotosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias(
        $_aliasNameGenerator(db.waypointPhotos.activityId, db.activities.id),
      );

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WaypointPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $WaypointPhotosTable> {
  $$WaypointPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceFromStartMeters => $composableBuilder(
    column: $table.distanceFromStartMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WaypointPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $WaypointPhotosTable> {
  $$WaypointPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceFromStartMeters => $composableBuilder(
    column: $table.distanceFromStartMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WaypointPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaypointPhotosTable> {
  $$WaypointPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceFromStartMeters => $composableBuilder(
    column: $table.distanceFromStartMeters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WaypointPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaypointPhotosTable,
          WaypointPhoto,
          $$WaypointPhotosTableFilterComposer,
          $$WaypointPhotosTableOrderingComposer,
          $$WaypointPhotosTableAnnotationComposer,
          $$WaypointPhotosTableCreateCompanionBuilder,
          $$WaypointPhotosTableUpdateCompanionBuilder,
          (WaypointPhoto, $$WaypointPhotosTableReferences),
          WaypointPhoto,
          PrefetchHooks Function({bool activityId})
        > {
  $$WaypointPhotosTableTableManager(
    _$AppDatabase db,
    $WaypointPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaypointPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaypointPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaypointPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> altitudeMeters = const Value.absent(),
                Value<double> distanceFromStartMeters = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaypointPhotosCompanion(
                id: id,
                activityId: activityId,
                filePath: filePath,
                latitude: latitude,
                longitude: longitude,
                altitudeMeters: altitudeMeters,
                distanceFromStartMeters: distanceFromStartMeters,
                takenAt: takenAt,
                caption: caption,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String activityId,
                required String filePath,
                required double latitude,
                required double longitude,
                required double altitudeMeters,
                required double distanceFromStartMeters,
                required DateTime takenAt,
                Value<String?> caption = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaypointPhotosCompanion.insert(
                id: id,
                activityId: activityId,
                filePath: filePath,
                latitude: latitude,
                longitude: longitude,
                altitudeMeters: altitudeMeters,
                distanceFromStartMeters: distanceFromStartMeters,
                takenAt: takenAt,
                caption: caption,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WaypointPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (activityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.activityId,
                                referencedTable: $$WaypointPhotosTableReferences
                                    ._activityIdTable(db),
                                referencedColumn:
                                    $$WaypointPhotosTableReferences
                                        ._activityIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WaypointPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaypointPhotosTable,
      WaypointPhoto,
      $$WaypointPhotosTableFilterComposer,
      $$WaypointPhotosTableOrderingComposer,
      $$WaypointPhotosTableAnnotationComposer,
      $$WaypointPhotosTableCreateCompanionBuilder,
      $$WaypointPhotosTableUpdateCompanionBuilder,
      (WaypointPhoto, $$WaypointPhotosTableReferences),
      WaypointPhoto,
      PrefetchHooks Function({bool activityId})
    >;
typedef $$GearsTableCreateCompanionBuilder =
    GearsCompanion Function({
      required String id,
      Value<String?> userId,
      required String name,
      required String gearType,
      Value<String?> brandModel,
      Value<double> totalDistanceMeters,
      Value<bool> isDefault,
      Value<bool> isRetired,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$GearsTableUpdateCompanionBuilder =
    GearsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> name,
      Value<String> gearType,
      Value<String?> brandModel,
      Value<double> totalDistanceMeters,
      Value<bool> isDefault,
      Value<bool> isRetired,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$GearsTableFilterComposer extends Composer<_$AppDatabase, $GearsTable> {
  $$GearsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gearType => $composableBuilder(
    column: $table.gearType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandModel => $composableBuilder(
    column: $table.brandModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalDistanceMeters => $composableBuilder(
    column: $table.totalDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRetired => $composableBuilder(
    column: $table.isRetired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GearsTableOrderingComposer
    extends Composer<_$AppDatabase, $GearsTable> {
  $$GearsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gearType => $composableBuilder(
    column: $table.gearType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandModel => $composableBuilder(
    column: $table.brandModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalDistanceMeters => $composableBuilder(
    column: $table.totalDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRetired => $composableBuilder(
    column: $table.isRetired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GearsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GearsTable> {
  $$GearsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get gearType =>
      $composableBuilder(column: $table.gearType, builder: (column) => column);

  GeneratedColumn<String> get brandModel => $composableBuilder(
    column: $table.brandModel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalDistanceMeters => $composableBuilder(
    column: $table.totalDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isRetired =>
      $composableBuilder(column: $table.isRetired, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GearsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GearsTable,
          Gear,
          $$GearsTableFilterComposer,
          $$GearsTableOrderingComposer,
          $$GearsTableAnnotationComposer,
          $$GearsTableCreateCompanionBuilder,
          $$GearsTableUpdateCompanionBuilder,
          (Gear, BaseReferences<_$AppDatabase, $GearsTable, Gear>),
          Gear,
          PrefetchHooks Function()
        > {
  $$GearsTableTableManager(_$AppDatabase db, $GearsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GearsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GearsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GearsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> gearType = const Value.absent(),
                Value<String?> brandModel = const Value.absent(),
                Value<double> totalDistanceMeters = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isRetired = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GearsCompanion(
                id: id,
                userId: userId,
                name: name,
                gearType: gearType,
                brandModel: brandModel,
                totalDistanceMeters: totalDistanceMeters,
                isDefault: isDefault,
                isRetired: isRetired,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String name,
                required String gearType,
                Value<String?> brandModel = const Value.absent(),
                Value<double> totalDistanceMeters = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isRetired = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => GearsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                gearType: gearType,
                brandModel: brandModel,
                totalDistanceMeters: totalDistanceMeters,
                isDefault: isDefault,
                isRetired: isRetired,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GearsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GearsTable,
      Gear,
      $$GearsTableFilterComposer,
      $$GearsTableOrderingComposer,
      $$GearsTableAnnotationComposer,
      $$GearsTableCreateCompanionBuilder,
      $$GearsTableUpdateCompanionBuilder,
      (Gear, BaseReferences<_$AppDatabase, $GearsTable, Gear>),
      Gear,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      required String id,
      required String displayName,
      Value<double> weightKg,
      Value<int> maxHeartRate,
      Value<int?> ftpWatts,
      Value<String> preferredUnit,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<double> weightKg,
      Value<int> maxHeartRate,
      Value<int?> ftpWatts,
      Value<String> preferredUnit,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ftpWatts => $composableBuilder(
    column: $table.ftpWatts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredUnit => $composableBuilder(
    column: $table.preferredUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ftpWatts => $composableBuilder(
    column: $table.ftpWatts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredUnit => $composableBuilder(
    column: $table.preferredUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ftpWatts =>
      $composableBuilder(column: $table.ftpWatts, builder: (column) => column);

  GeneratedColumn<String> get preferredUnit => $composableBuilder(
    column: $table.preferredUnit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> maxHeartRate = const Value.absent(),
                Value<int?> ftpWatts = const Value.absent(),
                Value<String> preferredUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                displayName: displayName,
                weightKg: weightKg,
                maxHeartRate: maxHeartRate,
                ftpWatts: ftpWatts,
                preferredUnit: preferredUnit,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<double> weightKg = const Value.absent(),
                Value<int> maxHeartRate = const Value.absent(),
                Value<int?> ftpWatts = const Value.absent(),
                Value<String> preferredUnit = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                weightKg: weightKg,
                maxHeartRate: maxHeartRate,
                ftpWatts: ftpWatts,
                preferredUnit: preferredUnit,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;
typedef $$SegmentsTableCreateCompanionBuilder =
    SegmentsCompanion Function({
      required String id,
      required String name,
      Value<String?> sportType,
      required String polylineJson,
      required double distanceM,
      required double startLat,
      required double startLon,
      required double endLat,
      required double endLon,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SegmentsTableUpdateCompanionBuilder =
    SegmentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> sportType,
      Value<String> polylineJson,
      Value<double> distanceM,
      Value<double> startLat,
      Value<double> startLon,
      Value<double> endLat,
      Value<double> endLon,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $SegmentsTable, Segment> {
  $$SegmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SegmentEffortsTable, List<SegmentEffort>>
  _segmentEffortsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.segmentEfforts,
    aliasName: $_aliasNameGenerator(
      db.segments.id,
      db.segmentEfforts.segmentId,
    ),
  );

  $$SegmentEffortsTableProcessedTableManager get segmentEffortsRefs {
    final manager = $$SegmentEffortsTableTableManager(
      $_db,
      $_db.segmentEfforts,
    ).filter((f) => f.segmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_segmentEffortsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sportType => $composableBuilder(
    column: $table.sportType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polylineJson => $composableBuilder(
    column: $table.polylineJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLat => $composableBuilder(
    column: $table.startLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLon => $composableBuilder(
    column: $table.startLon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLat => $composableBuilder(
    column: $table.endLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLon => $composableBuilder(
    column: $table.endLon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> segmentEffortsRefs(
    Expression<bool> Function($$SegmentEffortsTableFilterComposer f) f,
  ) {
    final $$SegmentEffortsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.segmentEfforts,
      getReferencedColumn: (t) => t.segmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentEffortsTableFilterComposer(
            $db: $db,
            $table: $db.segmentEfforts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sportType => $composableBuilder(
    column: $table.sportType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polylineJson => $composableBuilder(
    column: $table.polylineJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLat => $composableBuilder(
    column: $table.startLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLon => $composableBuilder(
    column: $table.startLon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLat => $composableBuilder(
    column: $table.endLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLon => $composableBuilder(
    column: $table.endLon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SegmentsTable> {
  $$SegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sportType =>
      $composableBuilder(column: $table.sportType, builder: (column) => column);

  GeneratedColumn<String> get polylineJson => $composableBuilder(
    column: $table.polylineJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get startLat =>
      $composableBuilder(column: $table.startLat, builder: (column) => column);

  GeneratedColumn<double> get startLon =>
      $composableBuilder(column: $table.startLon, builder: (column) => column);

  GeneratedColumn<double> get endLat =>
      $composableBuilder(column: $table.endLat, builder: (column) => column);

  GeneratedColumn<double> get endLon =>
      $composableBuilder(column: $table.endLon, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> segmentEffortsRefs<T extends Object>(
    Expression<T> Function($$SegmentEffortsTableAnnotationComposer a) f,
  ) {
    final $$SegmentEffortsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.segmentEfforts,
      getReferencedColumn: (t) => t.segmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentEffortsTableAnnotationComposer(
            $db: $db,
            $table: $db.segmentEfforts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SegmentsTable,
          Segment,
          $$SegmentsTableFilterComposer,
          $$SegmentsTableOrderingComposer,
          $$SegmentsTableAnnotationComposer,
          $$SegmentsTableCreateCompanionBuilder,
          $$SegmentsTableUpdateCompanionBuilder,
          (Segment, $$SegmentsTableReferences),
          Segment,
          PrefetchHooks Function({bool segmentEffortsRefs})
        > {
  $$SegmentsTableTableManager(_$AppDatabase db, $SegmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sportType = const Value.absent(),
                Value<String> polylineJson = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<double> startLat = const Value.absent(),
                Value<double> startLon = const Value.absent(),
                Value<double> endLat = const Value.absent(),
                Value<double> endLon = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SegmentsCompanion(
                id: id,
                name: name,
                sportType: sportType,
                polylineJson: polylineJson,
                distanceM: distanceM,
                startLat: startLat,
                startLon: startLon,
                endLat: endLat,
                endLon: endLon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> sportType = const Value.absent(),
                required String polylineJson,
                required double distanceM,
                required double startLat,
                required double startLon,
                required double endLat,
                required double endLon,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SegmentsCompanion.insert(
                id: id,
                name: name,
                sportType: sportType,
                polylineJson: polylineJson,
                distanceM: distanceM,
                startLat: startLat,
                startLon: startLon,
                endLat: endLat,
                endLon: endLon,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({segmentEffortsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (segmentEffortsRefs) db.segmentEfforts,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (segmentEffortsRefs)
                    await $_getPrefetchedData(
                      currentTable: table,
                      referencedTable: $$SegmentsTableReferences
                          ._segmentEffortsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SegmentsTableReferences(
                        db,
                        table,
                        p0,
                      ).segmentEffortsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.segmentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SegmentsTable,
      Segment,
      $$SegmentsTableFilterComposer,
      $$SegmentsTableOrderingComposer,
      $$SegmentsTableAnnotationComposer,
      $$SegmentsTableCreateCompanionBuilder,
      $$SegmentsTableUpdateCompanionBuilder,
      (Segment, $$SegmentsTableReferences),
      Segment,
      PrefetchHooks Function({bool segmentEffortsRefs})
    >;
typedef $$SegmentEffortsTableCreateCompanionBuilder =
    SegmentEffortsCompanion Function({
      required String id,
      required String segmentId,
      required String activityId,
      required int elapsedS,
      required DateTime startedAt,
      Value<String> progressJson,
      Value<int> rowid,
    });
typedef $$SegmentEffortsTableUpdateCompanionBuilder =
    SegmentEffortsCompanion Function({
      Value<String> id,
      Value<String> segmentId,
      Value<String> activityId,
      Value<int> elapsedS,
      Value<DateTime> startedAt,
      Value<String> progressJson,
      Value<int> rowid,
    });

final class $$SegmentEffortsTableReferences
    extends BaseReferences<_$AppDatabase, $SegmentEffortsTable, SegmentEffort> {
  $$SegmentEffortsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SegmentsTable _segmentIdTable(_$AppDatabase db) =>
      db.segments.createAlias(
        $_aliasNameGenerator(db.segmentEfforts.segmentId, db.segments.id),
      );

  $$SegmentsTableProcessedTableManager get segmentId {
    final $_column = $_itemColumn<String>('segment_id')!;

    final manager = $$SegmentsTableTableManager(
      $_db,
      $_db.segments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_segmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SegmentEffortsTableFilterComposer
    extends Composer<_$AppDatabase, $SegmentEffortsTable> {
  $$SegmentEffortsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedS => $composableBuilder(
    column: $table.elapsedS,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get progressJson => $composableBuilder(
    column: $table.progressJson,
    builder: (column) => ColumnFilters(column),
  );

  $$SegmentsTableFilterComposer get segmentId {
    final $$SegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableFilterComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SegmentEffortsTableOrderingComposer
    extends Composer<_$AppDatabase, $SegmentEffortsTable> {
  $$SegmentEffortsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedS => $composableBuilder(
    column: $table.elapsedS,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progressJson => $composableBuilder(
    column: $table.progressJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$SegmentsTableOrderingComposer get segmentId {
    final $$SegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SegmentEffortsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SegmentEffortsTable> {
  $$SegmentEffortsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activityId => $composableBuilder(
    column: $table.activityId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedS =>
      $composableBuilder(column: $table.elapsedS, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get progressJson => $composableBuilder(
    column: $table.progressJson,
    builder: (column) => column,
  );

  $$SegmentsTableAnnotationComposer get segmentId {
    final $$SegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.segments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.segments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SegmentEffortsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SegmentEffortsTable,
          SegmentEffort,
          $$SegmentEffortsTableFilterComposer,
          $$SegmentEffortsTableOrderingComposer,
          $$SegmentEffortsTableAnnotationComposer,
          $$SegmentEffortsTableCreateCompanionBuilder,
          $$SegmentEffortsTableUpdateCompanionBuilder,
          (SegmentEffort, $$SegmentEffortsTableReferences),
          SegmentEffort,
          PrefetchHooks Function({bool segmentId})
        > {
  $$SegmentEffortsTableTableManager(
    _$AppDatabase db,
    $SegmentEffortsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SegmentEffortsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SegmentEffortsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SegmentEffortsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> segmentId = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<int> elapsedS = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<String> progressJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SegmentEffortsCompanion(
                id: id,
                segmentId: segmentId,
                activityId: activityId,
                elapsedS: elapsedS,
                startedAt: startedAt,
                progressJson: progressJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String segmentId,
                required String activityId,
                required int elapsedS,
                required DateTime startedAt,
                Value<String> progressJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SegmentEffortsCompanion.insert(
                id: id,
                segmentId: segmentId,
                activityId: activityId,
                elapsedS: elapsedS,
                startedAt: startedAt,
                progressJson: progressJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SegmentEffortsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({segmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (segmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.segmentId,
                                referencedTable: $$SegmentEffortsTableReferences
                                    ._segmentIdTable(db),
                                referencedColumn:
                                    $$SegmentEffortsTableReferences
                                        ._segmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SegmentEffortsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SegmentEffortsTable,
      SegmentEffort,
      $$SegmentEffortsTableFilterComposer,
      $$SegmentEffortsTableOrderingComposer,
      $$SegmentEffortsTableAnnotationComposer,
      $$SegmentEffortsTableCreateCompanionBuilder,
      $$SegmentEffortsTableUpdateCompanionBuilder,
      (SegmentEffort, $$SegmentEffortsTableReferences),
      SegmentEffort,
      PrefetchHooks Function({bool segmentId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      required String id,
      required String name,
      required String muscleGroup,
      Value<String> equipment,
      Value<bool> isCustom,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> muscleGroup,
      Value<String> equipment,
      Value<bool> isCustom,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
  _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSets,
    aliasName: $_aliasNameGenerator(db.exercises.id, db.workoutSets.exerciseId),
  );

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager(
      $_db,
      $_db.workoutSets,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WorkoutTemplateItemsTable,
    List<WorkoutTemplateItem>
  >
  _workoutTemplateItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutTemplateItems,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.workoutTemplateItems.exerciseId,
        ),
      );

  $$WorkoutTemplateItemsTableProcessedTableManager
  get workoutTemplateItemsRefs {
    final manager = $$WorkoutTemplateItemsTableTableManager(
      $_db,
      $_db.workoutTemplateItems,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutTemplateItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutSetsRefs(
    Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutTemplateItemsRefs(
    Expression<bool> Function($$WorkoutTemplateItemsTableFilterComposer f) f,
  ) {
    final $$WorkoutTemplateItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutTemplateItems,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplateItemsTableFilterComposer(
            $db: $db,
            $table: $db.workoutTemplateItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> workoutSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutTemplateItemsRefs<T extends Object>(
    Expression<T> Function($$WorkoutTemplateItemsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutTemplateItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutTemplateItems,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutTemplateItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutTemplateItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool workoutSetsRefs,
            bool workoutTemplateItemsRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> muscleGroup = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                muscleGroup: muscleGroup,
                equipment: equipment,
                isCustom: isCustom,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String muscleGroup,
                Value<String> equipment = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                muscleGroup: muscleGroup,
                equipment: equipment,
                isCustom: isCustom,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutSetsRefs = false, workoutTemplateItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutSetsRefs) db.workoutSets,
                    if (workoutTemplateItemsRefs) db.workoutTemplateItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutSetsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutTemplateItemsRefs)
                        await $_getPrefetchedData(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutTemplateItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutTemplateItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool workoutSetsRefs,
        bool workoutTemplateItemsRefs,
      })
    >;
typedef $$WorkoutSetsTableCreateCompanionBuilder =
    WorkoutSetsCompanion Function({
      required String id,
      required String activityId,
      required String exerciseId,
      required int exerciseOrder,
      required int setIndex,
      Value<int?> reps,
      Value<double?> weightKg,
      Value<double?> rpe,
      Value<bool> isWarmup,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$WorkoutSetsTableUpdateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<String> id,
      Value<String> activityId,
      Value<String> exerciseId,
      Value<int> exerciseOrder,
      Value<int> setIndex,
      Value<int?> reps,
      Value<double?> weightKg,
      Value<double?> rpe,
      Value<bool> isWarmup,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ActivitiesTable _activityIdTable(_$AppDatabase db) =>
      db.activities.createAlias(
        $_aliasNameGenerator(db.workoutSets.activityId, db.activities.id),
      );

  $$ActivitiesTableProcessedTableManager get activityId {
    final $_column = $_itemColumn<String>('activity_id')!;

    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_activityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.workoutSets.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exerciseOrder => $composableBuilder(
    column: $table.exerciseOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ActivitiesTableFilterComposer get activityId {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exerciseOrder => $composableBuilder(
    column: $table.exerciseOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ActivitiesTableOrderingComposer get activityId {
    final $$ActivitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableOrderingComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get exerciseOrder => $composableBuilder(
    column: $table.exerciseOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<bool> get isWarmup =>
      $composableBuilder(column: $table.isWarmup, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$ActivitiesTableAnnotationComposer get activityId {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.activityId,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSetsTable,
          WorkoutSet,
          $$WorkoutSetsTableFilterComposer,
          $$WorkoutSetsTableOrderingComposer,
          $$WorkoutSetsTableAnnotationComposer,
          $$WorkoutSetsTableCreateCompanionBuilder,
          $$WorkoutSetsTableUpdateCompanionBuilder,
          (WorkoutSet, $$WorkoutSetsTableReferences),
          WorkoutSet,
          PrefetchHooks Function({bool activityId, bool exerciseId})
        > {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> activityId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> exerciseOrder = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSetsCompanion(
                id: id,
                activityId: activityId,
                exerciseId: exerciseId,
                exerciseOrder: exerciseOrder,
                setIndex: setIndex,
                reps: reps,
                weightKg: weightKg,
                rpe: rpe,
                isWarmup: isWarmup,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String activityId,
                required String exerciseId,
                required int exerciseOrder,
                required int setIndex,
                Value<int?> reps = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSetsCompanion.insert(
                id: id,
                activityId: activityId,
                exerciseId: exerciseId,
                exerciseOrder: exerciseOrder,
                setIndex: setIndex,
                reps: reps,
                weightKg: weightKg,
                rpe: rpe,
                isWarmup: isWarmup,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activityId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (activityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.activityId,
                                referencedTable: $$WorkoutSetsTableReferences
                                    ._activityIdTable(db),
                                referencedColumn: $$WorkoutSetsTableReferences
                                    ._activityIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$WorkoutSetsTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$WorkoutSetsTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSetsTable,
      WorkoutSet,
      $$WorkoutSetsTableFilterComposer,
      $$WorkoutSetsTableOrderingComposer,
      $$WorkoutSetsTableAnnotationComposer,
      $$WorkoutSetsTableCreateCompanionBuilder,
      $$WorkoutSetsTableUpdateCompanionBuilder,
      (WorkoutSet, $$WorkoutSetsTableReferences),
      WorkoutSet,
      PrefetchHooks Function({bool activityId, bool exerciseId})
    >;
typedef $$WorkoutTemplatesTableCreateCompanionBuilder =
    WorkoutTemplatesCompanion Function({
      required String id,
      required String name,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WorkoutTemplatesTableUpdateCompanionBuilder =
    WorkoutTemplatesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WorkoutTemplatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutTemplatesTable, WorkoutTemplate> {
  $$WorkoutTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $WorkoutTemplateItemsTable,
    List<WorkoutTemplateItem>
  >
  _workoutTemplateItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutTemplateItems,
        aliasName: $_aliasNameGenerator(
          db.workoutTemplates.id,
          db.workoutTemplateItems.templateId,
        ),
      );

  $$WorkoutTemplateItemsTableProcessedTableManager
  get workoutTemplateItemsRefs {
    final manager = $$WorkoutTemplateItemsTableTableManager(
      $_db,
      $_db.workoutTemplateItems,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutTemplateItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutTemplateItemsRefs(
    Expression<bool> Function($$WorkoutTemplateItemsTableFilterComposer f) f,
  ) {
    final $$WorkoutTemplateItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutTemplateItems,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplateItemsTableFilterComposer(
            $db: $db,
            $table: $db.workoutTemplateItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTemplatesTable> {
  $$WorkoutTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> workoutTemplateItemsRefs<T extends Object>(
    Expression<T> Function($$WorkoutTemplateItemsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutTemplateItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutTemplateItems,
          getReferencedColumn: (t) => t.templateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutTemplateItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutTemplateItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTemplatesTable,
          WorkoutTemplate,
          $$WorkoutTemplatesTableFilterComposer,
          $$WorkoutTemplatesTableOrderingComposer,
          $$WorkoutTemplatesTableAnnotationComposer,
          $$WorkoutTemplatesTableCreateCompanionBuilder,
          $$WorkoutTemplatesTableUpdateCompanionBuilder,
          (WorkoutTemplate, $$WorkoutTemplatesTableReferences),
          WorkoutTemplate,
          PrefetchHooks Function({bool workoutTemplateItemsRefs})
        > {
  $$WorkoutTemplatesTableTableManager(
    _$AppDatabase db,
    $WorkoutTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplatesCompanion(
                id: id,
                name: name,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplatesCompanion.insert(
                id: id,
                name: name,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workoutTemplateItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutTemplateItemsRefs) db.workoutTemplateItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutTemplateItemsRefs)
                    await $_getPrefetchedData(
                      currentTable: table,
                      referencedTable: $$WorkoutTemplatesTableReferences
                          ._workoutTemplateItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutTemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).workoutTemplateItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.templateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTemplatesTable,
      WorkoutTemplate,
      $$WorkoutTemplatesTableFilterComposer,
      $$WorkoutTemplatesTableOrderingComposer,
      $$WorkoutTemplatesTableAnnotationComposer,
      $$WorkoutTemplatesTableCreateCompanionBuilder,
      $$WorkoutTemplatesTableUpdateCompanionBuilder,
      (WorkoutTemplate, $$WorkoutTemplatesTableReferences),
      WorkoutTemplate,
      PrefetchHooks Function({bool workoutTemplateItemsRefs})
    >;
typedef $$WorkoutTemplateItemsTableCreateCompanionBuilder =
    WorkoutTemplateItemsCompanion Function({
      required String id,
      required String templateId,
      required String exerciseId,
      required int itemOrder,
      Value<int> targetSets,
      Value<int> targetReps,
      Value<int> rowid,
    });
typedef $$WorkoutTemplateItemsTableUpdateCompanionBuilder =
    WorkoutTemplateItemsCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<String> exerciseId,
      Value<int> itemOrder,
      Value<int> targetSets,
      Value<int> targetReps,
      Value<int> rowid,
    });

final class $$WorkoutTemplateItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutTemplateItemsTable,
          WorkoutTemplateItem
        > {
  $$WorkoutTemplateItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutTemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.workoutTemplates.createAlias(
        $_aliasNameGenerator(
          db.workoutTemplateItems.templateId,
          db.workoutTemplates.id,
        ),
      );

  $$WorkoutTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $$WorkoutTemplatesTableTableManager(
      $_db,
      $_db.workoutTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(
          db.workoutTemplateItems.exerciseId,
          db.exercises.id,
        ),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutTemplateItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutTemplateItemsTable> {
  $$WorkoutTemplateItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemOrder => $composableBuilder(
    column: $table.itemOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutTemplatesTableFilterComposer get templateId {
    final $$WorkoutTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutTemplateItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutTemplateItemsTable> {
  $$WorkoutTemplateItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemOrder => $composableBuilder(
    column: $table.itemOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutTemplatesTableOrderingComposer get templateId {
    final $$WorkoutTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutTemplateItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutTemplateItemsTable> {
  $$WorkoutTemplateItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get itemOrder =>
      $composableBuilder(column: $table.itemOrder, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => column,
  );

  $$WorkoutTemplatesTableAnnotationComposer get templateId {
    final $$WorkoutTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.workoutTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutTemplateItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutTemplateItemsTable,
          WorkoutTemplateItem,
          $$WorkoutTemplateItemsTableFilterComposer,
          $$WorkoutTemplateItemsTableOrderingComposer,
          $$WorkoutTemplateItemsTableAnnotationComposer,
          $$WorkoutTemplateItemsTableCreateCompanionBuilder,
          $$WorkoutTemplateItemsTableUpdateCompanionBuilder,
          (WorkoutTemplateItem, $$WorkoutTemplateItemsTableReferences),
          WorkoutTemplateItem,
          PrefetchHooks Function({bool templateId, bool exerciseId})
        > {
  $$WorkoutTemplateItemsTableTableManager(
    _$AppDatabase db,
    $WorkoutTemplateItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutTemplateItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutTemplateItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkoutTemplateItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> itemOrder = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int> targetReps = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplateItemsCompanion(
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                itemOrder: itemOrder,
                targetSets: targetSets,
                targetReps: targetReps,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required String exerciseId,
                required int itemOrder,
                Value<int> targetSets = const Value.absent(),
                Value<int> targetReps = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutTemplateItemsCompanion.insert(
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                itemOrder: itemOrder,
                targetSets: targetSets,
                targetReps: targetReps,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutTemplateItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (templateId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.templateId,
                                referencedTable:
                                    $$WorkoutTemplateItemsTableReferences
                                        ._templateIdTable(db),
                                referencedColumn:
                                    $$WorkoutTemplateItemsTableReferences
                                        ._templateIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$WorkoutTemplateItemsTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$WorkoutTemplateItemsTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutTemplateItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutTemplateItemsTable,
      WorkoutTemplateItem,
      $$WorkoutTemplateItemsTableFilterComposer,
      $$WorkoutTemplateItemsTableOrderingComposer,
      $$WorkoutTemplateItemsTableAnnotationComposer,
      $$WorkoutTemplateItemsTableCreateCompanionBuilder,
      $$WorkoutTemplateItemsTableUpdateCompanionBuilder,
      (WorkoutTemplateItem, $$WorkoutTemplateItemsTableReferences),
      WorkoutTemplateItem,
      PrefetchHooks Function({bool templateId, bool exerciseId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$TrackPointsTableTableManager get trackPoints =>
      $$TrackPointsTableTableManager(_db, _db.trackPoints);
  $$WaypointPhotosTableTableManager get waypointPhotos =>
      $$WaypointPhotosTableTableManager(_db, _db.waypointPhotos);
  $$GearsTableTableManager get gears =>
      $$GearsTableTableManager(_db, _db.gears);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$SegmentsTableTableManager get segments =>
      $$SegmentsTableTableManager(_db, _db.segments);
  $$SegmentEffortsTableTableManager get segmentEfforts =>
      $$SegmentEffortsTableTableManager(_db, _db.segmentEfforts);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$WorkoutTemplatesTableTableManager get workoutTemplates =>
      $$WorkoutTemplatesTableTableManager(_db, _db.workoutTemplates);
  $$WorkoutTemplateItemsTableTableManager get workoutTemplateItems =>
      $$WorkoutTemplateItemsTableTableManager(_db, _db.workoutTemplateItems);
}
