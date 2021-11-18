import 'package:client/appConstants.dart';
import 'package:client/appLocalizations.dart';
import 'package:client/components/toastNotification.dart';
import 'package:client/models/cloudConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:client/components/topBar.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfigurationDetails extends StatefulWidget {
  ConfigurationDetails({Key key}) : super(key: key);
  
  @override
  _ConfigurationDetailsState createState() => _ConfigurationDetailsState();
}

class _ConfigurationDetailsState extends State<ConfigurationDetails> {
  final _formKey = GlobalKey<FormState>();
  CloudConfiguration _cloudConfiguration;
  String _selectedConfigurationId;
  bool _isNew = false;

  @override
  Widget build(BuildContext context) {
    _selectedConfigurationId = CloudConfiguration.loadSelectedConfigurationId();
    if (ModalRoute.of(context).settings.arguments != null) {
      _cloudConfiguration = ModalRoute.of(context).settings.arguments as CloudConfiguration;
    } else {
      _cloudConfiguration = CloudConfiguration();
      _isNew = true;
    }
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
         if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: TopBar(context, AppLocalizations.of(context).configurationDetailsScreenTitle, 
          action: _isNew ? null : () { deleteConfiguration(); },
          actionIcon: _isNew ? null : Icons.delete_outline_outlined,
          onPop: _isNew ? null : saveConfiguration
        ),
        body: Form(
          key: _formKey,
          child:
            SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ------ General
                Container(
                  padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
                  child: Text(AppLocalizations.of(context).generalConfigurationGroupName, 
                    textAlign: TextAlign.left,
                    style: GoogleFonts.mulish(fontStyle: FontStyle.italic))
                ),
                Divider(indent: 10, endIndent: 10, thickness: 2),
                TextFormField(
                  validator: (customName) {
                    if (customName.isEmpty) {
                      return AppLocalizations.of(context).missingConfigurationNameNotification;
                    } else {
                      return null;
                    }
                  },
                  initialValue: _cloudConfiguration.customName,
                  onSaved: (value) { _cloudConfiguration.customName = value; },
                  decoration: const InputDecoration(
                    errorStyle: TextStyle(),
                    prefixIcon: Icon(Icons.tag_outlined),
                    border: InputBorder.none,
                    labelText: 'Custom name',
                    hintText: 'staging environment',
                    contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  ),
                ),
                TextFormField(
                  validator: (url) {
                    final pattern = r'[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)';
                    final regex = RegExp(pattern);
                    if (!regex.hasMatch(url)) {
                      return AppLocalizations.of(context).invalidEndpointNotification;
                    } else {
                      return null;
                    }
                  },
                  initialValue: _cloudConfiguration.plgdAPIEndpoint,
                  onSaved: (value) { _cloudConfiguration.plgdAPIEndpoint = value; },
                  decoration: const InputDecoration(
                    errorStyle: TextStyle(),
                    prefixIcon: Icon(Icons.insert_link_rounded),
                    border: InputBorder.none,
                    labelText: 'plgd API Endpoint',
                    hintText: '192.168.0.103',
                    prefixText: 'https://',
                    contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  ),
                ),
              
              // ------ OAuth
                Container(
                  padding: EdgeInsets.fromLTRB(10, 45, 0, 0),
                  child: Text(AppLocalizations.of(context).authorizationConfigurationGroupName, 
                    textAlign: TextAlign.left,
                    style: GoogleFonts.mulish(fontStyle: FontStyle.italic))
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(AppLocalizations.of(context).skipOAuthConfigurationHint, 
                    textAlign: TextAlign.left,
                    style: GoogleFonts.mulish(fontStyle: FontStyle.italic, fontSize: 10, color: AppConstants.mainColor))
                ),
                Divider(indent: 10, endIndent: 10, thickness: 2),
                TextFormField(
                  initialValue: _cloudConfiguration.authorizationServer,
                  onSaved: (value) { _cloudConfiguration.authorizationServer = value.isEmpty ? _removeApiPrefix(_cloudConfiguration.plgdAPIEndpoint) : value; },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.insert_link_rounded),
                    border: InputBorder.none,
                    labelText: 'Authorization Server',
                    hintText: 'mytenant.auth0.com',
                    prefixText: 'https://',
                    contentPadding: EdgeInsets.all(10)
                  ),
                ),

                // ------ OAuth Mobile
                ExpansionTile(
                  maintainState: true,
                  title: Text(AppLocalizations.of(context).mobileAppOAuthClientConfigurationGroupName,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.mulish(fontStyle: FontStyle.italic)
                  ),
                  children: [
                    TextFormField(
                      initialValue: _cloudConfiguration.mobileAppAuthClientId,
                      onSaved: (value) { _cloudConfiguration.mobileAppAuthClientId = value.isEmpty ? 'test' : value; },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: InputBorder.none,
                        labelText: 'Client ID',
                        hintText: 'LXZ9OhWRYW0B5OXduq',
                        contentPadding: EdgeInsets.all(10)
                      ),
                    ),
                    TextFormField(
                      initialValue: _cloudConfiguration.mobileAppAudience,
                      onSaved: (value) { _cloudConfiguration.mobileAppAudience = value; },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.shield_outlined),
                        border: InputBorder.none,
                        labelText: 'Audience',
                        hintText: 'https://try.plgd.cloud',
                        contentPadding: EdgeInsets.all(10)
                      ),
                    ),
                    TextFormField(
                      initialValue: _cloudConfiguration.mobileAuthScopes,
                      onSaved: (value) { _cloudConfiguration.mobileAuthScopes = value; },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.code_outlined),
                        border: InputBorder.none,
                        labelText: 'Scopes',
                        hintText: 'r:*,w:*',
                        contentPadding: EdgeInsets.all(10)
                      ),
                    ),

                    Icon(Icons.warning_amber_rounded, color: AppConstants.yellowMainColor),
                    Text('Set \'${AppConstants.authRedirectUri}\' as allowed redirect url.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mulish(fontStyle: FontStyle.italic, fontSize: 11, color: AppConstants.mainColor)
                    ),
                  ]
                ),

                // ------ OAuth Device
                ExpansionTile(
                  maintainState: true,
                  title: Text(AppLocalizations.of(context).deviceOAuthClientConfigurationGroupName,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.mulish(fontStyle: FontStyle.italic)
                  ),
                  children: [
                    TextFormField(
                      initialValue: _cloudConfiguration.deviceAuthProvider,
                      onSaved: (value) { _cloudConfiguration.deviceAuthProvider = value.isEmpty ? AppConstants.deviceAuthProvider : value; },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: InputBorder.none,
                        labelText: 'Authorization Provider Name',
                        hintText: 'plgd.mobileapp',
                        contentPadding: EdgeInsets.all(10)
                      ),
                    ),
                    TextFormField(
                      initialValue: _cloudConfiguration.deviceAuthClientId,
                      onSaved: (value) { _cloudConfiguration.deviceAuthClientId = value.isEmpty ? 'test' : value; },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: InputBorder.none,
                        labelText: 'Client ID',
                        hintText: 'LXZ9OhWRYW0B5OXduq',
                        contentPadding: EdgeInsets.all(10)
                      ),
                    ),
                    TextFormField(
                      initialValue: _cloudConfiguration.deviceAuthAudience,
                      onSaved: (value) { _cloudConfiguration.deviceAuthAudience = value; },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.shield_outlined),
                        border: InputBorder.none,
                        labelText: 'Audience',
                        hintText: 'https://try.plgd.cloud',
                        contentPadding: EdgeInsets.all(10)
                      ),
                    ),
                    TextFormField(
                      initialValue: _cloudConfiguration.deviceAuthScopes,
                      onSaved: (value) { _cloudConfiguration.deviceAuthScopes = value; },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.code_outlined),
                        border: InputBorder.none,
                        labelText: 'Scopes',
                        hintText: 'r:devices,w:devices',
                        contentPadding: EdgeInsets.all(10)
                      ),
                    ),

                    Icon(Icons.warning_amber_rounded, color: AppConstants.yellowMainColor),
                    Text(AppLocalizations.of(context).setDefaultRedirectUrlHint,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mulish(fontStyle: FontStyle.italic, fontSize: 11, color: AppConstants.mainColor)
                    ),
                  ]
                ),
                Visibility(
                  visible: _isNew,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(60, 20, 60, 0),
                    child: FlatButton(
                      onPressed: () async { await saveConfiguration(); },
                      color: AppConstants.mainColor,
                      splashColor: AppConstants.yellowMainColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, color: Colors.white),
                          SizedBox(width: 10),
                          Text(AppLocalizations.of(context).saveConfigurationButton, style: GoogleFonts.mulish(color: Colors.white, fontSize: 14))
                        ]
                      )
                    )
                  )
                )
              ],
            )
          )
        )
      )
    );
  }

  String _removeApiPrefix(String apiEndpoint) {
    if (apiEndpoint.startsWith('api.')) {
      return apiEndpoint.substring(4);
    }
    return apiEndpoint;
  }
  Future<void> saveConfiguration() async {
    if (!_formKey.currentState.validate()) {
        return;
    }
    _formKey.currentState.save();
    if(!await _cloudConfiguration.setOpenIdConfiguration()) {
      ToastNotification.show(context, AppLocalizations.of(context).unableToFetchOpenIdConfigurationNotification);
      return;
    }

    var cloudConfigurations = await CloudConfiguration.addOrUpdate(_cloudConfiguration);
    Navigator.pop(context, cloudConfigurations);
  }

  Future<void> deleteConfiguration() async {
    if (_cloudConfiguration.id == _selectedConfigurationId) {
      _selectedConfigurationId = CloudConfiguration.defaultId;
      await CloudConfiguration.saveSelectedConfigurationId(_selectedConfigurationId);
    }
    var cloudConfigurations = CloudConfiguration.load();
    cloudConfigurations.removeWhere((cfg) => cfg.id == _cloudConfiguration.id);
    await CloudConfiguration.save(cloudConfigurations);
    Navigator.pop(context, cloudConfigurations);
  }
}