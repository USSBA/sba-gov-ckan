
@core_helper
def google_analytics_id():
  return config.get('google_analytics.id', 'UA-000000-0')
