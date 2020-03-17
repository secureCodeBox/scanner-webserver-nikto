class NiktoCommandBuilder
	# @param [NiktoConfiguration] configuration
	def initialize(configuration, filename)
		@config = configuration
		@filename = filename
	end

	def build
		command_parts = [
			'perl /sectools/nikto-master/program/nikto.pl',
			'-F csv',
			"-o #{@filename}",
			"-h \"#{@config.nikto_target}\"",
		]

		if ENV.has_key? 'DEBUG'
			command_parts.push '-maxtime 2s'
		end

		if !@config.nikto_target.nil? and @config.nikto_ports != ''
			command_parts.push "-p #{@config.nikto_ports}"
		end
		if !@config.nikto_parameter.nil? and @config.nikto_parameter != ''
			command_parts.push @config.nikto_parameter
		end

		command_parts.join " "
	end
end
