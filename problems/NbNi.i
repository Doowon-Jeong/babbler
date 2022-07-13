#
# KKS toy problem in the non-split form
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  nz = 0
  xmin = -0.5
  xmax = 0.5
  ymin = -0.5
  ymax = 0.5
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  # order parameter
  [./eta]
    order = THIRD
    family = HERMITE
  [../]

  # niobium concentration
  [./c]
    order = THIRD
    family = HERMITE
  [../]

  # niobium phase concentration (fcc phase)
  [./cf]
    order = THIRD
    family = HERMITE
    initial_condition = 0.357
  [../]
  # niobium phase concentration (bcc phase)
  [./cb]
    order = THIRD
    family = HERMITE
    initial_condition = 0.880
  [../]
[]

[ICs]
  [./eta]
    variable = eta
    type = SmoothCircleIC
    x1 = 0.0
    y1 = 0.0
    radius = 0.2
    invalue = 0.6
    outvalue = 0.4
    int_width = 0.05
  [../]
  [./c]
    variable = c
    type = SmoothCircleIC
    x1 = 0.0
    y1 = 0.0
    radius = 0.2
    invalue = 0.6
    outvalue = 0.4
    int_width = 0.05
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      variable = 'eta c cf cb'
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
  # Free energy of the fcc phase
  [./ff]
    type = DerivativeParsedMaterial
    f_name = ff
    args = 'cf'
    function = 'cf * (-8519.353 + 142.045475 * T - 26.4711 * T * log(T) '
               '+ 0.000203475 * T^2 - 0.000000350119 * T^3 + 93399.0 * T^(-1) '
               '+ 13500.0 + 1.7 * T)'
               '+ (1.0 - cf) * (-5179.159 + 117.854 * T - 22.096 * T * log(T) '
               '- 0.0048407 * T^2)'
               '+ R * T * (cf * log(cf) + (1.0 - cf) * log(1.0 - cf)) + '
               '((-36499.0 - 15.24689 * T) + '
               '(+94812.0) * (2.0 * cf - 1.0)) * cf * (1.0 - cf)'
    constant_names       = 'R     T      '
    constant_expressions = '8.314 1273.15'
    outputs = oversampling
  [../]

  # Free energy of the bcc phase
  [./fb]
    type = DerivativeParsedMaterial
    f_name = fb
    args = 'cb'
    function = 'cb * (-8519.353 + 142.045475 * T - 26.4711 * T * log(T) '
               '+ 0.000203475 * T^2 - 0.000000350119 * T^3 + 93399.0 * T^(-1))'
               '+ (1.0 - cb) * (-5179.159 + 117.854 * T - 22.096 * T * log(T) '
               '- 0.0048407 * T^2 + 8715.084 - 3.556 * T)'
               '+ R * T * (cb * log(cb) + (1.0 - cb) * log(1.0 - cb)) '
               '+ (-22463.0 + 4.89296 * T) * cb * (1.0 - cb)'
    constant_names       = 'R     T      '
    constant_expressions = '8.314 1273.15'
    outputs = oversampling
  [../]

  # h(eta)
  [./h_eta]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    eta = eta
    outputs = oversampling
  [../]

  # g(eta)
  [./g_eta]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta
    outputs = oversampling
  [../]

  # constant properties
  [./constants]
    type = GenericConstantMaterial
    prop_names  = 'L  '
    prop_values = '1.0'
  [../]
[]

[Kernels]
  # enforce c = (1-h(eta))*cf + h(eta)*cb
  [./PhaseConc]
    type = KKSPhaseConcentration
    ca       = cf
    variable = cb
    c        = c
    eta      = eta
  [../]

  # enforce pointwise equality of chemical potentials
  [./ChemPotVacancies]
    type = KKSPhaseChemicalPotential
    variable = cf
    cb       = cb
    fa_name  = ff
    fb_name  = fb
  [../]

  #
  # Cahn-Hilliard Equation
  #
  [./CHBulk]
    type = KKSCHBulk
    variable = c
    ca       = cf
    cb       = cb
    fa_name  = ff
    fb_name  = fb
    mob_name = 1.0
  [../]
  [./dcbt]
    type = TimeDerivative
    variable = c
  [../]

  #
  # Allen-Cahn Equation
  #
  [./ACBulkF]
    type = KKSACBulkF
    variable = eta
    fa_name  = ff
    fb_name  = fb
    args     = 'cf cb'
    w        = 1.0
  [../]
  [./ACBulkC]
    type = KKSACBulkC
    variable = eta
    ca       = cf
    cb       = cb
    fa_name  = ff
  [../]
  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = 1.0
  [../]
  [./detadt]
    type = TimeDerivative
    variable = eta
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = ' asm      lu           nonzero'

  l_max_its = 1000
  nl_max_its = 1000
  nl_rel_tol = 1e-4

  num_steps = 1

  dt = 0.01
  dtmin = 0.01
[]

[Preconditioning]
  [./mydebug]
    type = SMP
    full = true
  [../]
[]

[Outputs]
  file_base = NbNi
  [./oversampling]
    type = Exodus
    refinements = 3
  [../]
[]
