# README

AWS ELB 를 사용하고자 하는 경우,
아래 두개의 파일명을 *.tf 로 변경하세요.

- elb.tf.optional
- outputs.tf.optional

자체 도메인을 이용해 ELB 에 접속하려면,
acm_subdomain 에서 기술된 https 인증서를 생성해야 합니다.

그 후, 아래 두개의 파일명을 *.tf 로 변경하세요.

- acm.tf.optional
- acm.domain.optional

마지막으로 elb.tf.optional 의 내용중
 lb_protocol, ssl_certificate_id 를 수정해 줍니다.