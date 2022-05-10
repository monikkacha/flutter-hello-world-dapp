import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  final String _rpcUrl =
      "https://rinkeby.infura.io/v3/227098c890ed489c8c0600f6b526c6b6";
  final String _wsUrl =
      "wss://rinkeby.infura.io/ws/v3/227098c890ed489c8c0600f6b526c6b6";
  final String _privateKey =
      "9e44b839acef2e5e16ba9d62b0190edc93e6cdfd748d6d4c5ffa6789a2f80e73";

  late Web3Client _client;
  bool isLoading = true;

  late String _abiCode;
  late EthereumAddress _contractAddress;

  late Credentials _credentials;

  late DeployedContract _contract;
  late ContractFunction _yourName;
  late ContractFunction _setName;

  late String deployedName;

  ContractLinking() {
    initialSetup();
  }

  initialSetup() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    await getAbi();
    await getCredentials();
    await getDeployedContracts();
  }

  getAbi() async {
    String abiStringFile = await rootBundle.loadString("asset/HelloWorld.js");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi['abi']);
    _contractAddress =
        EthereumAddress.fromHex("0x84c47b0c22Fd20f5210A58d315B511c0321F2f42");
  }

  getCredentials() async {
    _credentials = await _client.credentialsFromPrivateKey(_privateKey);
  }

  getDeployedContracts() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "HelloWorld"), _contractAddress);
    _yourName = _contract.function("yourName");
    _setName = _contract.function("setName");
    getName();
  }

  getName() async {
    var currentName = await _client
        .call(contract: _contract, function: _yourName, params: []);
    deployedName = currentName[0];
    isLoading = false;
    notifyListeners();
  }

  setName(String _nameToSet) async {
    try {
      isLoading = true;
      notifyListeners();
      await _client.sendTransaction(
          _credentials,
          Transaction.callContract(
              // from: EthereumAddress.fromHex(_privateKey),
              contract: _contract,
              function: _setName,
              parameters: [_nameToSet]),
          chainId: 4);
      getName();
    } catch (e) {
      print("${e}");
      isLoading = false;
      notifyListeners();
    }
  }
}
