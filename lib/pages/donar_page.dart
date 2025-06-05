import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonarPage extends StatelessWidget {
  const DonarPage({super.key});

  static final List<Map<String, String>> _wallets = [
    {"name": "Bitcoin (BTC)", "address": "bc1qexamplebtc1234567890"},
    {"name": "Ethereum (ETH)", "address": "0xexampleeth1234567890abcdef"},
    {"name": "Tether (USDT)", "address": "0xexampleusdt1234567890"},
    {"name": "BNB", "address": "bnbexampleaddress123456"},
    {"name": "Cardano (ADA)", "address": "addr1qexampleada1234567890"},
    {"name": "Solana (SOL)", "address": "5exampleSolana123456789"},
    {"name": "Litecoin (LTC)", "address": "ltc1qexampleltc1234567890"},
    {"name": "Polkadot (DOT)", "address": "1exampleDotAddress1234"},
    {"name": "Ripple (XRP)", "address": "rExampleRippleAddressXRP"},
    {"name": "Monero (XMR)", "address": "4exampleXMRaddress123456"},
  ];

  void _copiar(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dirección copiada al portapapeles")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Apoya al desarrollador"),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.redAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Sebastian Lara - RK13",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Desarrollador de herramientas éticas para Termux y promotor de la programación como vía para el cambio.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 30),
            const Text(
              "Elige tu criptomoneda favorita y copia la dirección para donar:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ..._wallets.map(
              (wallet) => Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    wallet['name']!,
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                  subtitle: Text(
                    wallet['address']!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () => _copiar(context, wallet['address']!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 28,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.favorite,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                label: const Text(
                  "DONAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gracias por tu apoyo ético!"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
