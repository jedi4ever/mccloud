#http://www.catapult-creative.com/2009/02/04/installing-rails-on-centos-5/

yum install -y httpd-devel openssl-devel zlib-devel gcc gcc-c++ curl-devel expat-devel gettext-devel

mkdir /usr/local/src
cd /usr/local/src
curl -O ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p72.tar.gz
tar xzvf ruby-1.8.7-p72.tar.gz
cd ruby-1.8.7-p72
./configure --enable-shared --enable-pthread
make
make install


cd /usr/local/src
wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
tar xzvf rubygems-1.3.5.tgz
cd rubygems-1.3.5
ruby setup.rb
gem install rubygems-update
update_rubygems


gem install chef --no-ri --no-rdoc
gem install puppet --no-ri --no-rdoc

