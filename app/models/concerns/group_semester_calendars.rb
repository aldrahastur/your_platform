concern :GroupSemesterCalendars do

  included do
    has_many :semester_calendars
  end

  # Regular groups just have events and do not use semester calendars.
  # For special groups that you want to use semester calendars to group
  # events, override this method and return true.
  #
  def use_semester_calendars?
    false
  end

  def semester_calendar
    semester_calendars.current.first
  end

  def semester_calendar!
    semester_calendars.current.first_or_create
  end

end