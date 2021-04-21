class TrainCargo < Train
  TYPE_TRAIN = 'cargo'.freeze

  def initialize(number)
    super(number, TYPE_TRAIN)
    @number = number
    self.register_instance
  end
end