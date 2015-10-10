FROM ubuntu:14.04
RUN apt-get update -qq && apt-get install -y git openssh-server

RUN mkdir /var/run/sshd
RUN sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

RUN mkdir -p /root/.ssh

RUN echo '' > /root/.ssh/authorized_keys
RUN echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCccUYMBFrQnhK/UhqDCcnJ+vXtQOpTglAkT8+10qbrCxWr35TFU9MOBkIIEhdKnL6GovlyE0slBZEkHtWzluvaETeDQzNB1UD9T1Yb4oHaknFvwby3w8dOTrU5kVJ+7DkEZeF38zNkgWw7WtK5ln5wH0ab00aPR7HVR1e/rKOZblsJiOKS9BnucdGsEDfl8uBsDJgE5WRxgoVIre2nuqvFYg/RRQEm3tFzfVAXXa1NL3pGf9o+4vjyt/6My270pjZdxMJ6Ip6kBZa+7gozr3CaTqSpilf8H5M8OOqKdTSXgkV5bcig8Z0z8hskwq89QcltVF1gBzreYtP4u8MV6Fft mail@theodorekimble.com' >> /root/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
