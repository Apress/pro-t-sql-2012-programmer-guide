using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;

namespace Apress.Examples
{
    [Serializable]
    [Microsoft.SqlServer.Server.SqlUserDefinedType
      (
        Format.Native,
        IsByteOrdered = true
      )]
    public struct Complex : INullable
    {

        #region "Complex Number UDT Fields/Components"

        private bool m_Null;
        public Double real;
        public Double imaginary;

        #endregion

        #region "Complex Number Parsing, Constructor, and Methods/Properties"

        private static readonly Regex rx = new Regex(
          "^(?<Imaginary>[+-]?([0-9]+|[0-9]*\\.[0-9]+))[i|I]$|" +
          "^(?<Real>[+-]?([0-9]+|[0-9]*\\.[0-9]+))$|" +
          "^(?<Real>[+-]?([0-9]+|[0-9]*\\.[0-9]+))" +
          "(?<Imaginary>[+-]?([0-9]+|[0-9]*\\.[0-9]+))[i|I]$");

        public static Complex Parse(SqlString s)
        {
            Complex u = new Complex();
            if (s.IsNull)
                u = Null;
            else
            {
                MatchCollection m = rx.Matches(s.Value);
                if (m.Count == 0)
                    throw (new FormatException("Invalid Complex Number Format."));
                String real_str = m[0].Groups["Real"].Value;
                String imaginary_str = m[0].Groups["Imaginary"].Value;
                if (real_str == "" && imaginary_str == "")
                    throw (new FormatException("Invalid Complex Number Format."));
                if (real_str == "")
                    u.real = 0.0;
                else
                    u.real = Convert.ToDouble(real_str);
                if (imaginary_str == "")
                    u.imaginary = 0.0;
                else
                    u.imaginary = Convert.ToDouble(imaginary_str);
            }
            return u;
        }

        public override String ToString()
        {
            String sign = "";
            if (this.imaginary >= 0.0)
                sign = "+";
            return this.real.ToString() + sign + this.imaginary.ToString() + "i";
        }

        public bool IsNull
        {
            get
            {
                return m_Null;
            }
        }

        public static Complex Null
        {
            get
            {
                Complex h = new Complex();
                h.m_Null = true;
                return h;
            }
        }

        public Complex(Double r, Double i)
        {
            this.real = r;
            this.imaginary = i;
            this.m_Null = false;
        }

        #endregion

        #region "Useful Complex Number Constants"

        // The property "i" is the Complex number 0 + 1i. Defined here because
        // it is useful in some calculations

        public static Complex i
        {
            get
            {
                return new Complex(0, 1);
            }
        }

        // The property "Pi" is the Complex representation of the number
        // Pi (3.141592... + 0i)

        public static Complex Pi
        {
            get
            {
                return new Complex(Math.PI, 0);
            }
        }

        // The property "One" is the Complex number representation of the
        // number 1 (1 + 0i)

        public static Complex One
        {
            get
            {
                return new Complex(1, 0);
            }
        }

        #endregion

        #region "Complex Number Basic Operators"

        // Complex number addition

        public static Complex operator +(Complex n1, Complex n2)
        {
            Complex u;
            if (n1.IsNull || n2.IsNull)
                u = Null;
            else
                u = new Complex(n1.real + n2.real, n1.imaginary + n2.imaginary);
            return u;
        }

        // Complex number subtraction

        public static Complex operator -(Complex n1, Complex n2)
        {
            Complex u;
            if (n1.IsNull || n2.IsNull)
                u = Null;
            else
                u = new Complex(n1.real - n2.real, n1.imaginary - n2.imaginary);
            return u;
        }

        // Complex number multiplication

        public static Complex operator *(Complex n1, Complex n2)
        {
            Complex u;
            if (n1.IsNull || n2.IsNull)
                u = Null;
            else
                u = new Complex((n1.real * n2.real) - (n1.imaginary * n2.imaginary),
                  (n1.real * n2.imaginary) + (n2.real * n1.imaginary));
            return u;
        }

        // Complex number division

        public static Complex operator /(Complex n1, Complex n2)
        {
            Complex u;
            if (n1.IsNull || n2.IsNull)
                u = Null;
            else
            {
                if (n2.real == 0.0 && n2.imaginary == 0.0)
                    throw new DivideByZeroException
                      ("Complex Number Division By Zero Exception.");
                u = new Complex(((n1.real * n2.real) +
                  (n1.imaginary * n2.imaginary)) /
                  ((Math.Pow(n2.real, 2) + Math.Pow(n2.imaginary, 2))),
                  ((n1.imaginary * n2.real) - (n1.real * n2.imaginary)) /
                  ((Math.Pow(n2.real, 2) + Math.Pow(n2.imaginary, 2))));
            }
            return u;
        }

        // Unary minus operator

        public static Complex operator -(Complex n1)
        {
            Complex u;
            if (n1.IsNull)
                u = Null;
            else
                u = new Complex(-n1.real, -n1.imaginary);
            return u;
        }

        #endregion

        #region "Exposed Mathematical Basic Operator Methods"

        // Add complex number n2 to n1

        public static Complex CAdd(Complex n1, Complex n2)
        {
            return n1 + n2;
        }

        // Subtract complex number n2 from n1

        public static Complex Sub(Complex n1, Complex n2)
        {
            return n1 - n2;
        }

        // Multiply complex number n1 * n2

        public static Complex Mult(Complex n1, Complex n2)
        {
            return n1 * n2;
        }

        // Divide complex number n1 by n2

        public static Complex Div(Complex n1, Complex n2)
        {
            return n1 / n2;
        }

        // Returns negated complex number

        public static Complex Neg(Complex n1)
        {
            return -n1;
        }

        #endregion

    }
}
