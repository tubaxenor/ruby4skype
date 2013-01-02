
Spec::Matchers.define :be_boolean do
  match do |actual|
    actual == true or actual == false
  end
#  failure_message_for_should do |actual|
#  end
#  failure_message_for_should_not do |actual|
#  end
end
