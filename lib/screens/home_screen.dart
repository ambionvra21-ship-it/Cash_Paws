Widget buildDashboardCard({required Widget child}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CashPawsColors.cardBackground,
      borderRadius: BorderRadius.circular(24), // Smoother, rounder modern corners
      border: Border.all(
        color: CashPawsColors.neonBlue.withOpacity(0.15), // Subtle neon outline
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
}
