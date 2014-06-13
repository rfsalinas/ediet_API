require 'rubygems'
require 'sinatra'
require 'sinatra/config_file'
require 'sequel'
require 'logger'
require 'sinatra/base'

config_file './database.yml'

DB = Sequel.connect(
    :adapter  => settings.ADAPTER,
    :host     => settings.HOST,
    :database => settings.DATABASE,
    :user     => settings.NAME,
    :password => settings.PASSWORD,
)

class DataBaseKanjo < Sinatra::Base
#set DB parameters with sequel

  #Crea tablas si no existen
  DB.create_table?(:UsersKanjo)do
    primary_key :idUser, :type => Bignum
    String      :name, :null => false
    String      :mail, :null => false
    #String      :password, :fixed =>true, :size => 64, :null => false
    DateTime    :creationDate, :null => false
  end

  DB.create_table?(:CompanyProvider)do
    primary_key :idProvider, :type => Bignum
    String      :NameProvider, :null => false
  end

  DB.create_table?(:UserDevice)do
    foreign_key :idUser, :UsersKanjo, :type => Bignum
    foreign_key :idProvider, :CompanyProvider,:type => Bignum
    String      :identificationProvider
    String      :phoneNumber
    String      :version
    primary_key [:idUser, :idProvider]
  end

  DB.create_table?(:Etapa)do
    primary_key :idEtapa, :type => Integer
    String      :NombreEtapa, :null =>false
  end

  DB.create_table?(:Profile)do
    foreign_key :idUser, :UsersKanjo, :type => Bignum
    foreign_key :idEtapa, :Etapa, :type => Integer
    primary_key [:idUser, :idEtapa]
    index [:idUser, :idEtapa]
  end

  DB.create_table?(:Porcion)do
    primary_key :idPorcion, :type => Integer
    String      :Descripcion, :null => false
  end

  DB.create_table?(:GrupoAlimentos)do
    primary_key :idGrupoAlimento, :type => Integer
    String      :Descripcion, :null => false
  end

  DB.create_table?(:Alimentos)do
    primary_key :idAlimento, :type => Integer
    foreign_key :idPorcion, :Porcion, :type => Integer
    String      :Descripcion, :null => false
    Integer     :CantidadPorcion, :null => false
  end

  DB.create_table?(:GrupoAlimentos_Alimentos)do
    foreign_key :idGrupoAlimento, :GrupoAlimentos, :type => Integer
    foreign_key :idAlimento, :Alimentos, :type => Integer
    #primary_key [:idGrupoAlimento, :idAlimento]
    #index [:idGrupoAlimento, :idAlimento]
  end

  DB.create_table?(:Horario)do
    primary_key :idHorario, :type => Integer
    String      :Descripcion, :null => false
    String      :TimeHorario, :null => false
    String      :Active, :null => false
  end

  DB.create_table?(:Etapa_Alimento)do
    foreign_key :idEtapa, :Etapa, :type => Integer
    foreign_key :idAlimento, :Alimentos, :type => Integer
    foreign_key :idHorario, :Horario, :type => Integer
    Integer     :CantidadGrupo, :null=>false
    #primary_key [:idEtapa, :idAlimento]
  end

  DB.create_table?(:GrupoPlatillos)do
    primary_key :idGrupoPlatillo, :type => Integer
    String      :Descripcion, :null => false
  end

  DB.create_table?(:Platillos)do
    primary_key :idPlatillo, :type => Integer
    foreign_key :idGrupoPlatillo, :GrupoPlatillos, :type => Integer
    String      :Descripcion, :null => false
    String      :Ingredientes, :null => false
    String      :Preparacion, :null => false
  end

  DB.create_table?(:Version)do
    primary_key :idVersion, :type => Integer
    String      :Descripcion, :null => false
  end

  #set Version 0
  versionK = DB[:Version]
  versionK.insert(:Descripcion => 'initial')
  puts "DB created"

  run! if app_file == $0
end