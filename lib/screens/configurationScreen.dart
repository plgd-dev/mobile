import 'package:client/appConstants.dart';
import 'package:client/models/cloudConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:client/components/topBar.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfigurationScreen extends StatefulWidget {
  ConfigurationScreen({Key key}) : super(key: key);

  @override
  _ConfigurationState createState() => _ConfigurationState();
}

class _ConfigurationState extends State<ConfigurationScreen> {
    List<CloudConfiguration> _cloudConfigurations;
    String _selectedConfigurationId;

  @override
  initState() {
    super.initState();
    _cloudConfigurations = CloudConfiguration.load();
    _selectedConfigurationId = CloudConfiguration.loadSelectedConfigurationId();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TopBar(context, 'Configuration',
        action: () { Navigator.of(context).pushNamed('/configurationDetails').then(_refreshAfterUpdate); },
        actionIcon: Icons.add,
        onPop: () {
          Navigator.pop(context, _cloudConfigurations
            .singleWhere((configuration) => configuration.id == _selectedConfigurationId));
        }
      ),
      body: ListView.builder(
        itemCount: _cloudConfigurations.length,
        itemBuilder: (context, index) {
          return _getItem(_cloudConfigurations, index);
        }
      )
    );
  }

  Widget _getItem(List<CloudConfiguration> cloudConfigurations, int index) {
    var cloudConfiguration = cloudConfigurations[index];
    var isDefault = cloudConfiguration.id == CloudConfiguration.defaultId;
    return ListTile(
      leading: Icon(Icons.check, size: 20, color: cloudConfiguration.id == _selectedConfigurationId ? AppConstants.mainColor : Colors.transparent),
      title: Text(cloudConfiguration.customName, style: GoogleFonts.mulish(color: Colors.black, fontSize: 15)),
      trailing: isDefault ? null : IconButton(
        icon: Icon(Icons.mode_edit_outline_outlined),
        iconSize: 20,
        onPressed: () { Navigator.of(context).pushNamed('/configurationDetails', arguments: cloudConfiguration).then(_refreshAfterUpdate); }
      ),
      subtitle: Text('${cloudConfiguration.plgdAPIEndpoint}', style: GoogleFonts.mulish(fontSize: 12)),
      minLeadingWidth: 10,
      onTap: () async {
        await CloudConfiguration.saveSelectedConfigurationId(cloudConfiguration.id);
        setState(() {
          _selectedConfigurationId = cloudConfiguration.id;
        });
      }
    );
  }

  void _refreshAfterUpdate(Object data) {
    var updatedConfiguration = data as List<CloudConfiguration>;
    if (updatedConfiguration != null) {
      setState(() {
        _selectedConfigurationId = CloudConfiguration.loadSelectedConfigurationId();
        _cloudConfigurations = updatedConfiguration;
      });
    }
  }
}