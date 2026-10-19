import 'package:flutter/material.dart';
import '../theme.dart';
import '../config.dart';

class PayoutScreen extends StatefulWidget {
  final int userBalance; // Pass current coins from the home dashboard
  
  const PayoutScreen({super.key, required this.userBalance});

  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _HomeScreenState extends State<PayoutScreen> {
  // Operational State Selections
  String selectedMethod = 'PayPal'; 
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isProcessing = false;

  final List<Map<String, String>> payoutMethods = [
    {'name': 'PayPal', 'sub': 'Global USD Payouts', 'icon': 'account_balance_wallet'},
    {'name': 'GCash', 'sub': 'PH Local Mobile Wallet', 'icon': 'phone_android'},
    {'name': 'Maya', 'sub': 'PH Premium Digital Bank', 'icon': 'credit_card'},
    {'name': 'ONE', 'sub': 'ONE Wallet Unified System', 'icon': 'star'},
  ];

  @override
  void dispose() {
    _accountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

    void _executeCashOutRequest() {
    double currentUsdValue = widget.userBalance * CashPawsConfig.coinToUsdMultiplier;
    
    // Profit Safeguard Check: Verify user has crossed the 2,000 coin ($2.00) rule
    if (currentUsdValue < CashPawsConfig.targetWithdrawalThreshold) {
      _showNotification(
        'Insufficient funds. You need at least \$${CashPawsConfig.targetWithdrawalThreshold.toStringAsFixed(2)} (2,000 Coins) to cash out.',
        isError: true,
      );
      return;
    }

    if (_accountController.text.isEmpty || _nameController.text.isEmpty) {
      _showNotification('Please fill in all account validation details.', isError: true);
      return;
    }

    setState(() { _isProcessing = true; });

    // Simulated network callback delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() { _isProcessing = false; });
      _showNotification('Success! Your $selectedMethod payout request has been queued for review.');
      _accountController.clear();
      _nameController.clear();
    });
  }

  void _showNotification(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.redAccent : CashPawsColors.rewardOrange,
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    double currentUsdValue = widget.userBalance * CashPawsConfig.coinToUsdMultiplier;
    bool canWithdraw = currentUsdValue >= CashPawsConfig.targetWithdrawalThreshold;

    return Scaffold(
      backgroundColor: CashPawsColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Redeem Rewards', style: TextStyle(color: CashPawsColors.textDark, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: CashPawsColors.textDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- 1. Current Progress Status Card ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: CashPawsColors.cardSurface, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('REDEEMABLE BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CashPawsColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('${widget.userBalance} Coins', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.black, color: CashPawsColors.textDark)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: CashPawsColors.backgroundLight, borderRadius: BorderRadius.circular(8)),
                      child: Text('\$${currentUsdValue.toStringAsFixed(2)} USD', style: const TextStyle(fontWeight: FontWeight.bold, color: CashPawsColors.rewardOrange)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('SELECT PAYOUT GATEWAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CashPawsColors.textSecondary)),
              const SizedBox(height: 8),

              // --- 2. Dynamic Payout Gateway List ---
              Column(
                children: payoutMethods.map((method) {
                  bool isSelected = selectedMethod == method['name'];
                  return Card(
                    color: CashPawsColors.cardSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: isSelected ? CashPawsColors.rewardOrange : Colors.transparent, width: 1.5),
                    ),
                    child: ListTile(
                      onTap: () { setState(() { selectedMethod = method['name']!; }); },
                      leading: Icon(
                        method['name'] == 'PayPal' ? Icons.account_balance_wallet :
                        method['name'] == 'GCash' ? Icons.phone_android :
                        method['name'] == 'Maya' ? Icons.credit_card : Icons.star,
                        color: isSelected ? CashPawsColors.rewardOrange : CashPawsColors.textSecondary,
                      ),
                      title: Text(method['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: CashPawsColors.textDark, fontSize: 14)),
                      subtitle: Text(method['sub']!, style: const TextStyle(fontSize: 11, color: CashPawsColors.textSecondary)),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: CashPawsColors.rewardOrange) : const SizedBox.shrink(),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              const Text('ACCOUNT INFORMATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CashPawsColors.textSecondary)),
              const SizedBox(height: 8),

              // --- 3. Structured Details Form Input Layout ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: CashPawsColors.cardSurface, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: CashPawsColors.textDark, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Full Registered Name',
                        labelStyle: const TextStyle(color: CashPawsColors.textSecondary, fontSize: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _accountController,
                      style: const TextStyle(color: CashPawsColors.textDark, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: selectedMethod == 'PayPal' ? 'PayPal Email Address' : '$selectedMethod Mobile Account Number',
                        labelStyle: const TextStyle(color: CashPawsColors.textSecondary, fontSize: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 4. Secured Submission Transaction Button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CashPawsColors.rewardOrange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: !canWithdraw || _isProcessing ? null : _executeCashOutRequest,
                child: _isProcessing 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(canWithdraw ? 'SUBMIT CASH-OUT REQUEST' : 'LOCKED (MINIMUM \$2.00 REQUIRED)', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
