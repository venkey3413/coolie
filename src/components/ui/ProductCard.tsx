import React from 'react';
import { Link } from 'react-router-dom';
import { ShoppingCart, Heart } from 'lucide-react';
import { Product, useStore } from '../../store/useStore';
import toast from 'react-hot-toast';

interface ProductCardProps {
  product: Product;
}

export const ProductCard: React.FC<ProductCardProps> = ({ product }) => {
  const { addToCart } = useStore();
  
  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    addToCart(product);
    toast.success(`${product.name} added to cart!`);
  };

  const mainImage = product.images?.[0] || 'https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg';

  return (
    <div className="group bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow duration-300 overflow-hidden">
      <Link to={`/products/${product.id}`} className="block">
        <div className="relative overflow-hidden">
          <img
            src={mainImage}
            alt={product.name}
            className="w-full h-64 object-cover group-hover:scale-105 transition-transform duration-300"
          />
          {product.is_featured && (
            <span className="absolute top-2 left-2 bg-orange-500 text-white text-xs px-2 py-1 rounded">
              Featured
            </span>
          )}
          {product.stock_quantity === 0 && (
            <span className="absolute top-2 right-2 bg-red-500 text-white text-xs px-2 py-1 rounded">
              Out of Stock
            </span>
          )}
          
          {/* Hover Actions */}
          <div className="absolute inset-0 bg-black bg-opacity-20 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center space-x-2">
            <button className="p-2 bg-white rounded-full shadow-md hover:bg-gray-50 transition-colors">
              <Heart className="w-4 h-4 text-gray-600" />
            </button>
            <button
              onClick={handleAddToCart}
              disabled={product.stock_quantity === 0}
              className="p-2 bg-orange-500 text-white rounded-full shadow-md hover:bg-orange-600 transition-colors disabled:bg-gray-400"
            >
              <ShoppingCart className="w-4 h-4" />
            </button>
          </div>
        </div>

        <div className="p-4">
          <h3 className="text-lg font-semibold text-gray-900 mb-2 line-clamp-2">
            {product.name}
          </h3>
          <p className="text-gray-600 text-sm mb-3 line-clamp-2">
            {product.description}
          </p>
          
          <div className="flex items-center justify-between">
            <span className="text-2xl font-bold text-orange-500">
              ${product.price.toFixed(2)}
            </span>
            {product.stock_quantity > 0 && (
              <span className="text-sm text-gray-500">
                {product.stock_quantity} in stock
              </span>
            )}
          </div>

          {product.categories && (
            <div className="mt-2">
              <span className="inline-block bg-gray-100 text-gray-600 text-xs px-2 py-1 rounded">
                {product.categories.name}
              </span>
            </div>
          )}
        </div>
      </Link>
    </div>
  );
};