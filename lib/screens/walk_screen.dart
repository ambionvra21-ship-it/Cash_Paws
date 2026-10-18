Widget buildGlowingProgress(double progressValue) {
  return Stack(
    alignment: Alignment.center,
    children: [
      // Track Background
      SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(
          value: 1.0,
          strokeWidth: 10,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.05)),
        ),
      ),
      // Glowing Neon Progress Arc
      SizedBox(
        width: 100,
        height: 100,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: CashPawsColors.neonGreen.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircularProgressIndicator(
            value: progressValue, // e.g., 0.75 for 3/4
            strokeWidth: 10,
            strokeCap: StrokeCap.round, // Smooth rounded edges on the arc bar
            valueColor: const AlwaysStoppedAnimation<Color>(CashPawsColors.neonGreen),
          ),
        ),
      ),
      // Center Text
      Text(
        "${(progressValue * 4).toInt()}/4",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
