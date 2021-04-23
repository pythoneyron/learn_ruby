require_relative 'modules'
require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'train_passenger'
require_relative 'train_cargo'
require_relative 'carriage'
require_relative 'carriage_passenger'
require_relative 'carriage_cargo'

class RailsRoad
  attr_reader :stations, :trains, :carriages, :routers

  def initialize
    @stations = []
    @trains = []
    @carriages = []
    @routers = []
  end

  CREATE_STATIONS = 1
  CREATE_TRAINS_AND_MANAGE = 2
  CREATE_CARRIAGES_AND_MANAGE_VOLUME = 3
  CREATE_ROUTERS_AND_MANAGE_STATIONS = 4
  SET_ROUTE_TO_TRAIN = 5
  ADD_CARRIAGES_TO_TRAIN = 6
  REMOVE_CARRIAGE_FROM_TRAIN = 7
  MOVING_TRAIN_ON_ROUTE = 8
  SHOW_STATIONS_AND_TRAINS_ON_STATION = 9

  # типы вагонов и поездов
  TYPE_PASSENGER = 'passenger'.freeze
  TYPE_CARGO = 'cargo'.freeze

  # для метода create_trains
  PASSENGER = 1
  CARGO = 2

  # для метода create_trains_and_manage
  CREATE_TRAINS = 1
  SHOW_CARRIAGES_IN_TRAIN = 2

  # для метода manage_station и add_remove_intermediate_stations
  ADD_STATION = 1
  DELETE_STATION = 2
  MANAGE_STATIONS_IN_ROUTERS = 2
  SHOW_STATIONS_IN_ROUTE = 3

  # для метода create_routers_and_manage_station
  ADD_CARRIAGE = 1
  USE_VOLUME_IN_CARRIAGE = 2
  SHOW_USED_VOLUME = 3

  # для метода moving_train_on_route
  MOVING_NEXT = 1
  MOVING_PREVIOUS = 2

  # для метода moving_train_on_route
  MOVEMENT_NEXT = 'next'.freeze
  MOVEMENT_PREVIOUS = 'previous'.freeze

  puts "Это программа абстрактной модели железной дороги"

  def menu_items
    puts "\n1 - Создавать станции"
    puts '2 - Создавать поезда и управлять ими (создавать, просматривать вагоны)'
    puts '3 - Создавать вагоны и управлять ими (создавать, занимать места/объем, просматривать занятое место/объем)'
    puts '4 - Создавать маршруты и управлять станциями в нем (создавать, удалять, просматривать)'
    puts '5 - Назначать маршрут поезду'
    puts '6 - Добавлять вагоны к поезду'
    puts '7 - Отцеплять вагоны от поезда'
    puts '8 - Перемещать поезд по маршруту вперед и назад'
    puts '9 - Просматривать список станций и список поездов на станции'
    puts "0 - Выход"
    print "\nВыберите нужный вариант: "
  end

  def generate_test_data
    # Тестовые данные
    # <-------------->
    station_moscow = Station.new('Москва')
    station_surgut = Station.new( 'Сургут')
    station_tymen = Station.new( 'Тюмень')
    @stations.push(station_moscow, station_surgut, station_tymen)

    route = Route.new(station_moscow, station_surgut)
    @routers << route

    route.add_intermediate_stations(station_tymen)

    train_cargo = TrainCargo.new('111-11')
    @trains << train_cargo

    train_pass = TrainPassenger.new('222-22')
    @trains << train_pass


    train_cargo.route=(route)
    train_pass.route=(route)

    carriage_cargo_platform = CarriageCargo.new('платформа', 100)
    @carriages << carriage_cargo_platform

    carriage_cargo_container = CarriageCargo.new('контейнер', 100)
    @carriages << carriage_cargo_container

    carriage_pass_restaurant = CarriagePassenger.new('ресторан', 58)
    @carriages << carriage_pass_restaurant

    carriage_pass_reserved_seat = CarriagePassenger.new('плацкарт', 74)
    @carriages << carriage_pass_reserved_seat

    train_cargo.add_carriage(carriage_cargo_platform)
    train_cargo.add_carriage(carriage_cargo_container)

    train_pass.add_carriage(carriage_pass_restaurant)
    train_pass.add_carriage(carriage_pass_reserved_seat)

    puts '<--- Начало отображения тестовых данных --->'
    station_moscow.all_trains_in_station { |train| puts "Поезд #{train.number} тип: #{train.type_train}" } # Передаем блок в фунцией отображения в нужном формате
    puts ''
    train_cargo.all_carriages_in_train { |carriage| puts "Вагон #{carriage.name} тип: #{carriage.type_carriage}" } # Передаем блок в фунцией отображения в нужном формате
    puts ''
    train_pass.all_carriages_in_train { |carriage| puts "Вагон #{carriage.name} тип: #{carriage.type_carriage}" } # Передаем блок в фунцией отображения в нужном формате
    puts '<--- Конец отображения тестовых данных --->'
  end

  def start_program
    generate_test_data # Вызов метода для генерации тестовых данных

    loop do
      menu_items

      option = gets.chomp.to_i
      break if option.zero?

      create_stations if option == CREATE_STATIONS
      create_trains_and_manage if option == CREATE_TRAINS_AND_MANAGE
      create_carriages_and_manage_volume if option == CREATE_CARRIAGES_AND_MANAGE_VOLUME
      create_routers_and_manage_station if option == CREATE_ROUTERS_AND_MANAGE_STATIONS
      set_route_to_train if option == SET_ROUTE_TO_TRAIN
      add_carriages_to_train if option == ADD_CARRIAGES_TO_TRAIN
      remove_carriage_from_train if option == REMOVE_CARRIAGE_FROM_TRAIN
      moving_train_on_route if option == MOVING_TRAIN_ON_ROUTE
      show_stations_and_trains_on_stations if option == SHOW_STATIONS_AND_TRAINS_ON_STATION
    end
  end

  def create_stations
    loop do
      print "\nВведите название станции или 0 что бы выйти: "

      name = gets.chomp
      return if name == '0'

      station = Station.new(name)
      @stations << station

      puts "Станция с названием '#{station.name}' создана." if station.valid?
    end
  end

  def show_train_in_station
    loop do
      return puts "\nСтанции не найдены" if stations.empty?

      display_stations(stations)

      print "\nВыберите номер станции для просмотра поездов или 0 что бы выйти: "
      stations_index = gets.chomp.to_i
      return if stations_index.zero?

      station = stations[stations_index - 1]

      next unless station

      puts "\nНа станции '#{station.name}' поездов еще нет" if station.trains.empty?

      puts "\nПоезда на станции #{station.name}:"
      station.trains.each { |train| puts "#{train.number} - #{train.type} кол-во вагонов: #{train.carriages.length}" }
      puts "\n" # раздилитель между списками
    end
  end

  def create_trains_and_manage
    loop do
      puts "\n1 - Создать поезда"
      puts '2 - Просмотреть вагоны у поезда'
      print "\nВведите значение или 0 что бы выйти: "

      option = gets.chomp.to_i

      return if option.zero?

      create_trains if option == CREATE_TRAINS
      show_carriages_in_train if option == SHOW_CARRIAGES_IN_TRAIN
    end
  end

  def create_trains
    loop do
      puts "\n1 - Пассажирский"
      puts '2 - Грузовой'
      print "\nВыберите тип поезда или 0 что бы выйти: "

      type = gets.chomp.to_i
      return if type.zero?

      if type == PASSENGER
        print "Введите номер пассажирского поезда в формате ХХХ-ХХ '-' не обязательно: "

        number = gets.chomp
        train_passenger = TrainPassenger.new(number)
        @trains << train_passenger

        puts "\nПассажирский поезд с номером '#{train_passenger.number}' создан.\n" if train_passenger.valid?
      end

      if type == CARGO
        print "Введите номер грузового поезда в формате ХХХ-ХХ '-' не обязательно: "

        number = gets.chomp
        train_cargo = TrainCargo.new(number)
        @trains << train_cargo

        puts "\nГрузовой поезд с номером '#{train_cargo.number}' создан.\n" if train_cargo.valid?
      end
    end
  end

  def show_carriages_in_train
    loop do
      puts "\nНиже выведен список ранее созданных поездов:"

      display_trains(trains)

      print "\nВыберите поезд или ведите 0 что бы выйти: "
      train = gets.chomp.to_i
      return if train.zero?

      train = trains[train - 1]
      carriages = train.carriages

      puts "\nНиже выведен список вагонов для поезда #{train.number}:" unless carriages.empty?
      puts "\nВагоны у поезда #{train.number} отсутствуют!:" if carriages.empty?

      display_carriages(carriages)
    end
  end

  def create_carriages_and_manage_volume
    loop do
      puts "\n1 - Создать вагон"
      puts '2 - Занять место или объем в вагоне'
      puts '3 - Просмотреть занятый объем или место в вагоне'
      print "\nВведите значение или 0 что бы выйти: "

      option = gets.chomp.to_i

      return if option.zero?

      create_carriages if option == ADD_CARRIAGE
      use_volume_is_carriage if option == USE_VOLUME_IN_CARRIAGE
      show_used_volume if option == SHOW_USED_VOLUME
    end
  end

  def create_carriages
    loop do
      puts "\n1 - Пассажирский"
      puts '2 - Грузовой'
      print "\nВыберите тип вагона или 0 что бы выйти: "

      type = gets.chomp.to_i
      return if type.zero?

      if type == PASSENGER
        print 'Введите название пассажирского вагона: '
        name = gets.chomp

        print 'Введите количество мест пассажирского вагона(число): '
        seat = gets.chomp

        carriage_passenger = CarriagePassenger.new(name, seat)
        @carriages << carriage_passenger

        puts "\nПассажирский вагон '#{carriage_passenger.name}' создан.\n" if carriage_passenger.valid?
      end

      if type == CARGO
        print 'Введите название грузового вагона: '
        name = gets.chomp

        print 'Введите объем грузового вагона(число): '
        volume = gets.chomp

        carriage_cargo = CarriageCargo.new(name, volume)
        @carriages << carriage_cargo

        puts "\nГрузовой вагон '#{carriage_cargo.name}' создан.\n" if carriage_cargo.valid?
      end
    end
  end

  def use_volume_is_carriage
    loop do
      carriage = display_list_carriages_and_get
      return if carriage == 0

      if carriage.type == TYPE_CARGO
        puts "Свободно #{carriage.free_volume} из #{carriage.size}"
        print "\nВведите объем, который необходимо занять: "

        volume = gets.chomp.to_i

        puts carriage.use_volume(volume)
      else
        puts carriage.use_volume
      end
    end
  end

  def show_used_volume
    loop do
      carriage = display_list_carriages_and_get
      return if carriage == 0

      puts "Свободно #{carriage.free_volume} из #{carriage.size}"
    end
  end

  def create_routers
    return puts "\nДля построения маршрута требуется как минимум две станции. Создайте станции в основном меню!" if stations.empty?

    puts "\nНиже выведен список ранее созданных станций:"

    display_stations(stations)

    print "\nВыберите номер первой станции или 0 что бы выйти: "
    first = gets.chomp.to_i
    return if first.zero?

    first_station = stations[first - 1]

    print "\nВыберите номер конечной станции или 0 что бы выйти: "
    last = gets.chomp.to_i
    return if last.zero?

    last_station = stations[last - 1]

    return puts 'Одна или две станции не выбраны. Маршрут не создан' if [first_station, last_station].include?(nil)

    if first_station != last_station
      route = Route.new(first_station, last_station)
      @routers << route

      puts "\nМаршрут со станциями '#{first_station.name}' и '#{last_station.name}' создан.\n"
    else
      puts and return "\nВыбраны несуществующие пункты меню или выбраны одинаковые станции. Маршрут не создан!\n"
    end

    puts "\n1 - Добавить промежуточные станции"
    puts '0 - Выход'
    print 'Введите значение: '

    option = gets.chomp.to_i
    return if option != 1

    puts "\n\nНиже выведен список ранее созданных станций: "

    add_remove_intermediate_stations(ADD_STATION, route)
  end

  def manage_station
    loop do
      return puts "\nДля управления станциями в маршруте необходимо создать маршрут. Создайте маршруты!" if routers.empty?

      puts "\nНиже выведен список ранее созданных маршрутов:"

      display_routers(routers)

      print "\nВыберите номер маршрута для редактирования или введите 0 что бы выйти: "
      route = gets.chomp.to_i

      return if route.zero?

      route = routers[route - 1]

      next unless route

      puts "\n1 - Добавить станцию в выбранном маршруте"
      puts '2 - Удалить станцию в выбранный маршруте'
      puts '0 - Выход'
      print 'Введите значение: '

      add_or_del = gets.chomp.to_i

      return if add_or_del.zero?
      next if add_or_del > 2

      puts "\nНиже выведен список ранее созданных станций: "

      add_remove_intermediate_stations(ADD_STATION, route) if add_or_del == ADD_STATION
      add_remove_intermediate_stations(DELETE_STATION, route) if add_or_del == DELETE_STATION
    end
  end

  def show_stations_in_route
    loop do
      return puts "\nДля просмотра станции в маршруте необходимо создать маршрут. Создайте маршруты!" if routers.empty?

      puts "\nНиже выведен список ранее созданных маршрутов:"

      display_routers(routers)

      print "\nВыбирите маршрут или введите 0 что бы выйти: "
      route = gets.chomp.to_i

      return if route.zero?

      route = routers[route - 1]

      next unless route

      stations = route.full_route
      display_stations(stations)
    end
  end

  def create_routers_and_manage_station
    loop do
      puts "\n1 - Создать маршрут"
      puts '2 - Добавить или удалить станции с маршрута'
      puts '3 - Просмотреть станции в маршруте'
      puts '0 - Выход'
      print 'Введите значение: '

      option = gets.chomp.to_i

      return if option.zero?

      create_routers if option == ADD_STATION
      manage_station if option == MANAGE_STATIONS_IN_ROUTERS
      show_stations_in_route if option == SHOW_STATIONS_IN_ROUTE
    end
  end

  def set_route_to_train
    return puts "\nДля назначения поезду маршрута необходимо создать поезд. Создайте поезда!" if trains.empty?
    puts "\nНиже выведен список ранее созданных поездов:"

    display_trains(trains)

    print "\nВыберите поезд или ведите 0 что бы выйти: "
    train = gets.chomp.to_i
    return if train.zero?

    train = trains[train - 1]

    return puts "\nДля назначения поезду маршрута необходимо создать маршрут. Создайте маршруты!" if routers.empty?
    puts "\nНиже выведен список ранее созданных маршрутов:"

    display_routers(routers)

    print 'Введите 0 что бы выйти: '
    route = gets.chomp.to_i
    return if route.zero?

    route = routers[route - 1]

    train.route=(route)
    puts "\nПоезду #{train.number} назначен маршрут #{route.start.name} -> #{route.stop.name}"
  end

  def add_carriages_to_train
    return puts "\nДля добавления вагонов к поезду необходимо создать поезд. Создайте поезда!" if trains.empty?
    puts "\nНиже выведен список ранее созданных поездов:"

    display_trains(trains)

    print "\nВыберите поезд или ведите 0 что бы выйти: "
    train = gets.chomp.to_i
    return if train.zero?

    train = trains[train - 1]

    carriages_by_type = carriages.filter{ |carriage| carriage.type == train.type }
    return puts "\nДля добавления вагонов к поезду необходимо создать вагоны. Создайте вагоны!" if carriages_by_type.empty?

    loop do
      puts "\nНиже выведен список ранее созданных вагонов:"

      display_carriages(carriages_by_type)

      print "\nВыберите вагон или ведите 0 что бы выйти: "
      carriage = gets.chomp.to_i
      return if carriage.zero?

      carriage = carriages_by_type[carriage - 1]
      next unless carriage

      puts ''
      puts train.add_carriage(carriage)
      puts ''
    end
  end

  def remove_carriage_from_train
    return puts "\nДля удаления вагонов к поезда необходимо создать поезд. Создайте поезда!" if trains.empty?
    puts "\nНиже выведен список ранее созданных поездов:"

    display_trains(trains)

    print "\nВыберите поезд или ведите 0 что бы выйти: "
    train = gets.chomp.to_i
    return if train.zero?

    train = trains[train - 1]
    return unless train

    loop do
      carriages = train.carriages

      return puts "\nУ поезда отсутствуют вагоны" if carriages.empty?
      puts "\nНиже выведен список ранее созданных вагонов:"

      display_carriages(carriages)

      print "\nВыберите вагон или ведите 0 что бы выйти: "
      carriage = gets.chomp.to_i
      return if carriage.zero?

      carriage = carriages[carriage - 1]
      next unless carriage

      puts ''
      puts train.remove_carriage(carriage)
    end
  end

  def moving_train_on_route
    return puts "\nДля перемещения поезда его необходимо создать. Создайте поезда!" if trains.empty?
    puts "\nНиже выведен список ранее созданных поездов:"

    display_trains(trains)

    print "\nВыберите поезд или ведите 0 что бы выйти: "
    train = gets.chomp.to_i
    return if train.zero?

    train = trains[train - 1]

    loop do
      puts "\n1 - Движение вперед"
      puts '2 - Движение назад'
      puts '0 - Выход'
      print 'Введите значение: '

      moving = gets.chomp.to_i
      return if moving.zero?

      puts train.movement_train_by_stations(MOVEMENT_NEXT) if moving == MOVING_NEXT
      puts train.movement_train_by_stations(MOVEMENT_PREVIOUS) if moving == MOVING_PREVIOUS
    end
  end

  def show_stations_and_trains_on_stations
    loop do
      return puts "\nСтанции не найдены" if stations.empty?

      display_stations(stations)

      print "\nВыберите номер станции для просмотра поездов или 0 что бы выйти: "
      stations_index = gets.chomp.to_i
      return if stations_index.zero?

      station = stations[stations_index - 1]

      next unless station

      puts "\nНа станции '#{station.name}' поездов еще нет" if station.trains.empty?

      puts "\nПоезда на станции #{station.name}:"
      station.trains.each { |train| puts "#{train.number} - тип #{train.type_train} кол-во вагонов: #{train.carriages.length}" }
      puts "\n" # раздилитель между списками

    end
  end

  def add_remove_intermediate_stations(action, route)
    loop do
      stations_list = action == DELETE_STATION ? route.full_route : stations
      display_stations(stations_list)

      print "\nВыберите номер промежуточной станции или 0 что бы выйти: "
      intermediate = gets.chomp.to_i
      return if intermediate.zero?

      intermediate = stations[intermediate - 1]

      next unless intermediate

      if action == ADD_STATION
        if route.full_route.include?(intermediate)
          puts "\nСтанция '#{intermediate.name}' ранее уже была добавлена в маршрут. Выберите другую станцию."
          next
        end

        route.add_intermediate_stations(intermediate)
        puts "\nПромежуточная станция '#{intermediate.name}' добавлена."
      else
        puts "\n" # # раздилитель между пунктами
        puts route.delete_intermediate_stations(intermediate)
      end
    end
  end

  private

  # Эти методы используются только в рамках текущего класса
  def display_stations(stations)
    stations.each_with_index { |station, index| puts "#{index + 1} - #{station.name}" }
  end

  def display_routers(routers)
    routers.each_with_index { |route, index| puts "#{index + 1} - #{route.start.name} -> #{route.stop.name}" }
  end

  def display_trains(trains)
    trains.each_with_index { |train, index| puts "#{index + 1} - #{train.number} тип: #{train.type_train}" }
  end

  def display_carriages(carriages)
    carriages.each_with_index { |carriage, index| puts "#{index + 1} - #{carriage.name} тип: #{carriage.type_carriage}" }
  end

  def display_list_carriages_and_get
    loop do
      puts "\nНиже выведен список всех ранее созданных вагонов:"

      display_carriages(carriages)

      print "\nВыберите вагон или ведите 0 что бы выйти: "
      carriage = gets.chomp.to_i
      return 0 if carriage.zero?

      carriage = carriages[carriage - 1]
      next unless carriage

      return carriage
    end
  end
end

RailsRoad.new.start_program
