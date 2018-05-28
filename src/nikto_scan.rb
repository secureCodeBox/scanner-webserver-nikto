require 'csv'
require 'securerandom'

require_relative './nikto_command_builder'

class NiktoExecutionService
	def execute(cmd)
		`#{cmd}`
	end
end

class NiktoScan
	attr_reader :raw_results
	attr_reader :results

	def initialize(scan_id, config, nikto_execution_service = NiktoExecutionService.new, uuid_provider = SecureRandom)
		@scan_id = scan_id
		@config = config
		@filename = "/tmp/report-#{@scan_id}.csv"
		@command_builder = NiktoCommandBuilder.new(@config, @filename)
		@nikto_execution_service = nikto_execution_service
		@uuid_provider = uuid_provider
	end

	def start
		command = @command_builder.build

		result = @nikto_execution_service.execute(command)

		@raw_results = import_results

		@results = transform_results @raw_results
	end

	def transform_results(raw_results)
		raw_results.select do |row|
			row.length == 7 && !row[6].empty?
		end.map do |row|
			{
				id: @uuid_provider.uuid,
				name: row[6],
				description: '',
				osi_layer: 'APPLICATION',
				reference: {
					id: row[3],
					source: row[3]
				},
				severity: 'INFORMATIONAL',
				location: "#{row[0]}:#{row[2]}#{row[5]}",
				attributes: {
					http_method: row[4],
					hostname: row[0],
					path: row[5],
					ip_address: row[1],
					port: row[2].to_i
				}
			}
		end
	end

	def import_results

		begin
			result_text_csv = File.open(@filename, 'r') {|file| file.read}
		rescue => e
			puts "Could not read result file"
			puts e.message
		end

		# Replacing " with "" to ensure that they will always be in pairs
		# A unterminated string will cause the csv parser to fail.
		result_text_csv = result_text_csv.gsub(/\\"/, '""')

		CSV.parse(result_text_csv)
	end
end
