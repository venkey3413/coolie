import React from 'react';
import { Link } from 'react-router-dom';
import { ShoppingCart, Search, Menu, User } from 'lucide-react';
import { useStore } from '../../store/useStore';

export const Header: React.FC = () => {
  const { cart, setCartOpen, user } = useStore();
  
  const cartItemsCount = cart.reduce((total, item) => total + item.quantity, 0);

  return (
    <header className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-gradient-to-r from-amber-500 to-orange-500 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-lg">C</span>
            </div>
            <span className="text-2xl font-bold text-gray-900">Coolie</span>
          </Link>

          {/* Navigation */}
          <nav className="hidden md:flex items-center space-x-8">
            <Link to="/" className="text-gray-700 hover:text-orange-500 transition-colors">
              Home
            </Link>
            <Link to="/products" className="text-gray-700 hover:text-orange-500 transition-colors">
              Products
            </Link>
            <Link to="/categories" className="text-gray-700 hover:text-orange-500 transition-colors">
              Categories
            </Link>
            <Link to="/about" className="text-gray-700 hover:text-orange-500 transition-colors">
              About
            </Link>
          </nav>

          {/* Search and Actions */}
          <div className="flex items-center space-x-4">
            <button className="p-2 text-gray-600 hover:text-orange-500 transition-colors">
              <Search className="w-5 h-5" />
            </button>
            
            {user ? (
              <Link to="/profile" className="p-2 text-gray-600 hover:text-orange-500 transition-colors">
                <User className="w-5 h-5" />
              </Link>
            ) : (
              <Link to="/login" className="text-sm font-medium text-orange-500 hover:text-orange-600 transition-colors">
                Sign In
              </Link>
            )}

            <button
              onClick={() => setCartOpen(true)}
              className="relative p-2 text-gray-600 hover:text-orange-500 transition-colors"
            >
              <ShoppingCart className="w-5 h-5" />
              {cartItemsCount > 0 && (
                <span className="absolute -top-1 -right-1 bg-orange-500 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                  {cartItemsCount}
                </span>
              )}
            </button>

            <button className="md:hidden p-2 text-gray-600 hover:text-orange-500 transition-colors">
              <Menu className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>
    </header>
  );
};