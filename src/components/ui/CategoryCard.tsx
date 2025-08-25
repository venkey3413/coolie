import React from 'react';
import { Link } from 'react-router-dom';
import { Category } from '../../store/useStore';

interface CategoryCardProps {
  category: Category;
}

export const CategoryCard: React.FC<CategoryCardProps> = ({ category }) => {
  return (
    <Link
      to={`/categories/${category.id}`}
      className="group block bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow duration-300 overflow-hidden"
    >
      <div className="relative overflow-hidden h-48">
        <img
          src={category.image_url || 'https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg'}
          alt={category.name}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
        />
        <div className="absolute inset-0 bg-black bg-opacity-20 group-hover:bg-opacity-30 transition-colors duration-300" />
        
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center text-white">
            <h3 className="text-xl font-bold mb-2">{category.name}</h3>
            {category.description && (
              <p className="text-sm opacity-90 max-w-xs">{category.description}</p>
            )}
          </div>
        </div>
      </div>
    </Link>
  );
};