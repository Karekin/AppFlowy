import 'package:flutter/material.dart';

import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/mobile/presentation/base/app_bar_actions.dart';
import 'package:appflowy/mobile/presentation/database/field/mobile_field_type_option_editor.dart';
import 'package:appflowy/plugins/database/application/field/field_backend_service.dart';
import 'package:appflowy/plugins/database/application/field/field_info.dart';
import 'package:appflowy/plugins/database/application/field/field_service.dart';
import 'package:appflowy/plugins/database/widgets/setting/field_visibility_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart';
import 'package:go_router/go_router.dart';

class MobileEditPropertyScreen extends StatefulWidget {
  const MobileEditPropertyScreen({
    super.key,
    required this.viewId,
    required this.field,
  });

  final String viewId;
  final FieldInfo field;

  static const routeName = '/edit_property';
  static const argViewId = 'view_id';
  static const argField = 'field';

  @override
  State<MobileEditPropertyScreen> createState() =>
      _MobileEditPropertyScreenState();
}

class _MobileEditPropertyScreenState extends State<MobileEditPropertyScreen> {
  late final FieldBackendService fieldService;
  late FieldOptionValues _fieldOptionValues;

  @override
  void initState() {
    super.initState();
    _fieldOptionValues = FieldOptionValues.fromField(field: widget.field.field);
    fieldService = FieldBackendService(
      viewId: widget.viewId,
      fieldId: widget.field.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewId = widget.viewId;
    final fieldId = widget.field.id;

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          context.pop(_fieldOptionValues);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: FlowyText.medium(
            LocaleKeys.grid_field_editProperty.tr(),
          ),
          elevation: 0,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
            ),
          ),
          leading: AppBarBackButton(
            onTap: () => context.pop(_fieldOptionValues),
          ),
        ),
        body: MobileFieldEditor(
          mode: FieldOptionMode.edit,
          isPrimary: widget.field.isPrimary,
          defaultValues: _fieldOptionValues,
          actions: [
            widget.field.fieldSettings?.visibility.isVisibleState() ?? true
                ? FieldOptionAction.hide
                : FieldOptionAction.show,
            FieldOptionAction.duplicate,
            FieldOptionAction.delete,
          ],
          onOptionValuesChanged: (newFieldOptionValues) {
            setState(() {
              _fieldOptionValues = newFieldOptionValues;
            });
          },
          onAction: (action) {
            final service = FieldServices(
              viewId: viewId,
              fieldId: fieldId,
            );
            switch (action) {
              case FieldOptionAction.delete:
                fieldService.delete();
                context.pop();
                return;
              case FieldOptionAction.duplicate:
                fieldService.duplicate();
                break;
              case FieldOptionAction.hide:
                service.hide();
                break;
              case FieldOptionAction.show:
                service.show();
                break;
            }
            context.pop(_fieldOptionValues);
          },
        ),
      ),
    );
  }
}
