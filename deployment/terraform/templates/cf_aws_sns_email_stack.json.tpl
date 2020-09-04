{
 "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "${RESOURCE_NAME}": {
      "Type": "AWS::SNS::Topic",
      "Properties": {
        "TopicName": "${TOPIC_NAME}",
        "DisplayName": "${DISPLAY_NAME}",
        "Subscription": [
          ${SNS_SUB_LIST}
        ]
      }
    }
  }
}