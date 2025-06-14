import 'package:flutter_data/flutter_data.dart';
import 'package:purplebase/purplebase.dart' as base;
import 'package:zapstore/models/nostr_adapter.dart';
import 'package:zapstore/models/release.dart';
import 'package:zapstore/models/user.dart';
import 'package:zapstore/utils/extensions.dart';

part 'file_metadata.g.dart';

@DataAdapter([NostrAdapter, FileMetadataAdapter])
class FileMetadata extends base.FileMetadata with DataModelMixin<FileMetadata> {
  final BelongsTo<Release> release;
  final BelongsTo<User> signer;

  @override
  Object? get id => event.id;

  FileMetadata.fromJson(super.map)
      : release = belongsTo(map['release']),
        signer = belongsTo(map['signer']),
        super.fromJson();

  Map<String, dynamic> toJson() => super.toMap();
}

mixin FileMetadataAdapter on Adapter<FileMetadata> {
  @override
  DeserializedData<FileMetadata> deserialize(Object? data, {String? key}) {
    final list = data is Iterable ? data : [data as Map];
    for (final e in list) {
      final map = e as Map<String, dynamic>;
      final isNewFormat = map['kind'] == 3063;
      if (isNewFormat) {
        // Map to old 1063
        map['kind'] = 1063;
        map['tags'].add([
          'min_sdk_version',
          base.BaseUtil.getTag(map['tags'], 'min_os_version')
        ]);
        map['tags'].add([
          'target_sdk_version',
          base.BaseUtil.getTag(map['tags'], 'target_os_version')
        ]);
      }
    }
    return super.deserialize(data);
  }
}
