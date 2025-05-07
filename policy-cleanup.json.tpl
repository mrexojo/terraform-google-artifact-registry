{
  "cleanup_policies": {
    "keep-recent-versions": {
      "action": "KEEP",
      "most_recent_versions": {
        "package_name_prefixes": ${package_prefixes},
        "keep_count": ${keep_count}
      }
    },
    "delete-old-versions": {
      "action": "DELETE",
      "condition": {
        "tag_state": "TAGGED",
        "tag_prefixes": ["dev-", "test-"],
        "older_than": "${older_than_days}d"
      }
    },
    "delete-untagged": {
      "action": "DELETE",
      "condition": {
        "tag_state": "UNTAGGED",
        "older_than": "${untagged_older_than}d"
      }
    }
  }
}