require "test_helper"

class AdminReportMailerTest < ActionMailer::TestCase
  test "bottleneck_summary" do
    mail = AdminReportMailer.bottleneck_summary
    assert_equal "Bottleneck summary", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
