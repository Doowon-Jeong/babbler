#pragma once

#include "Material.h"

#include "LinearInterpolation.h"

class PackedColumn : public Material
{
public:
  static InputParameters validParams();

  PackedColumn(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  const Real & _diameter;
  const Real & _input_viscosity;

  LinearInterpolation _permeability_interpolation;

  ADMaterialProperty<Real> & _permeability;
  ADMaterialProperty<Real> & _viscosity;
};
