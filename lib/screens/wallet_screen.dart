Widget buildGlowingButton({required String text, required VoidCallback onPressed}) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient: CashPawsColors.primaryGradient,
      borderRadius: BorderRadius.circular(28), // Fully rounded capsule look
      boxShadow: [
        BoxShadow(
          color: CashPawsColors.neonBlue.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 4), // Generates a soft neon under-glow
        ),
      ],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
}
