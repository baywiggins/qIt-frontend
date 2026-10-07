class Config {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '/api/v1',
  );
  static const publicUrl = String.fromEnvironment(
    'PUBLIC_URL',
    defaultValue: 'http://localhost:8081',
  );
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const demo = bool.fromEnvironment('DEMO_MODE');
  static String roomLink(String code) => '$publicUrl/r/$code';
}
