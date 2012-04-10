MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'garry_development'
  when :production  then MongoMapper.database = 'garry_production'
  when :test        then MongoMapper.database = 'garry_test'
end
