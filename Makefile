run_all:
	@rvm 1.9.2,1.9.3,2.0.0 do rvm gemset create rubythumbor
	@rvm 1.9.2@rubythumbor,1.9.3@rubythumbor,2.0.0@rubythumbor do bundle
	@rvm 1.9.2@rubythumbor,1.9.3@rubythumbor,2.0.0@rubythumbor do bundle exec rake spec
