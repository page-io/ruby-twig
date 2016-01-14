# <?php
#
# /*
#  # This file is part of Twig.
#  #
#  # (c) 2009 Fabien Potencier
#  #
#  # For the full copyright and license information, please view the LICENSE
#  # file that was distributed with this source code.

#
# @trigger_error('The Twig_Node_Expression_ExtensionReference class is deprecated and will be removed in 2.0.', E_USER_DEPRECATED);
#

#  # Represents an extension call node.
#  #
#  # @author Fabien Potencier <fabien@symfony.com>
#  #
#  # @deprecated (to be removed in 2.0)

# class Twig_Node_Expression_ExtensionReference extends Twig_Node_Expression
# {
#     def initialize($name, $lineno, $tag = null)
#     {
#         parent::__construct([], array('name' => $name), $lineno, $tag);
#     end
#
#     def compile(compiler)
#     {
#         compiler.raw(sprintf("\$this->env->getExtension('%s')", $this.get_attribute('name')));
#     end
# end
