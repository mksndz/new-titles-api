# frozen_string_literal: true

# Pull Report - Testing new Style
task :get_new_titles, %i[institution type] => :environment do |_, args|
  slack = Slack::Notifier.new Rails.application.secrets.slack_worker_webhook

  # ensure valid type
  raise StandardError unless %w[physical electronic].include? args[:type]

  # validate and set institutions
  institution = Institution.find_by_shortcode args[:institution]
  raise StandardError unless institution
  slack.ping "Getting new `#{args[:type]}` titles for `#{institution.name}`"

  # initiate and pull report
  report = TitlesReport.new institution, args[:type]

  # get titles from report
  titles = report.titles
  if titles.any?
    outcome = Title.sync titles
    slack.ping "New titles for `#{institution.shortcode}` updated. `#{outcome[:new]}` titles added and `#{outcome[:expired]}` expired."
  else
    slack.ping "No new titles received for `#{institution.shortcode}`"
  end

end