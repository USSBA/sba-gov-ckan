
@core_helper
def google_analytics_id():
  return config.get('google_analytics.id', None)

@core_helper
def google_analytics_enabled():
  return len(google_analytics_id()) > 0
